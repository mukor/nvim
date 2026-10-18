-- Headless smoke test for this config. Run via test/run.sh, or directly:
--   nvim --headless --cmd "luafile test/smoke.lua"
--
-- Loaded with --cmd so the error hooks are in place before init.lua runs.
-- After startup it checks plugins, force-loads every lazy plugin, opens
-- sample files per filetype (parsing treesitter injections), then scans
-- :messages for errors. Exits non-zero if anything failed.

-- Lets the config skip side effects that a short-lived nvim would break
vim.g.smoke_test = true

local failures, warnings = {}, {}
local notified = {}

local function out(line)
	io.stdout:write(line .. "\n")
end

local function fail(what, detail)
	table.insert(failures, what)
	out("  FAIL  " .. what .. (detail and ("\n        " .. detail:gsub("\n", "\n        ")) or ""))
end

local function warn(what)
	table.insert(warnings, what)
	out("  WARN  " .. what)
end

local function pass(what)
	out("  ok    " .. what)
end

-- Capture vim.notify errors (lazy.nvim reports plugin config errors this way)
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
	if level and level >= vim.log.levels.ERROR then
		table.insert(notified, tostring(msg))
	end
	return orig_notify(msg, level, opts)
end

local function section(name)
	out("\n" .. name)
end

local function check_plugins()
	section "Plugins"
	local Plugin = require "lazy.core.plugin"
	local plugins = require("lazy").plugins()
	local bad = 0
	for _, p in ipairs(plugins) do
		if not p._.installed then
			fail(p.name .. " not installed (run :Lazy sync)")
			bad = bad + 1
		elseif Plugin.has_errors(p) then
			fail(p.name .. " has failed lazy tasks (see :Lazy)")
			bad = bad + 1
		end
	end
	if bad == 0 then
		pass(#plugins .. " plugins installed, no task errors")
	end
end

local function load_all()
	section "Load every plugin"
	local names = {}
	for _, p in ipairs(require("lazy").plugins()) do
		if not p._.loaded then
			table.insert(names, p.name)
		end
	end
	local before = #notified
	for _, name in ipairs(names) do
		local ok, err = pcall(require("lazy").load, { plugins = { name } })
		if not ok then
			fail("load " .. name, tostring(err))
		end
	end
	if #notified == before then
		pass("loaded " .. #names .. " lazy plugins")
	end
end

local samples = {
	markdown = {
		"md",
		[==[
---
title: smoke
tags: [test]
---
# Heading

Some *emphasis*, a [[wiki-link]] and #tag.

```lua
local x = 1
```

```python
def f(): return 1
```
]==],
	},
	python = { "py", "import os\n\n\ndef main() -> None:\n\tprint(os.getcwd())\n" },
	lua = { "lua", "local M = {}\nfunction M.f() return 1 end\nreturn M\n" },
	json = { "json", '{ "a": [1, 2, 3] }\n' },
	html = { "html", "<!doctype html><html><body><script>let a = 1</script></body></html>\n" },
	css = { "css", "body { color: red; }\n" },
}

local function check_filetypes()
	section "Filetypes (treesitter + ftplugins)"
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	for ft, sample in vim.spairs(samples) do
		local path = dir .. "/sample." .. sample[1]
		vim.fn.writefile(vim.split(sample[2], "\n"), path)
		local before = #notified
		local ok, err = pcall(function()
			vim.cmd.edit(vim.fn.fnameescape(path))
			assert(vim.bo.filetype == ft, "filetype is '" .. vim.bo.filetype .. "', expected '" .. ft .. "'")
			local parser = vim.treesitter.get_parser(0, nil, { error = false })
			if parser then
				-- parse(true) also parses injected languages (fenced code blocks)
				parser:parse(true)
			end
			vim.cmd.redraw()
		end)
		vim.wait(200)
		if not ok then
			fail(ft, tostring(err))
		elseif #notified > before then
			fail(ft, table.concat(vim.list_slice(notified, before + 1), "\n"))
		elseif not vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
			warn(ft .. ": opened, but treesitter highlighting is not active")
		else
			pass(ft)
		end
		vim.cmd "silent! bwipeout!"
	end
	vim.fn.delete(dir, "rf")
end

local function check_mason()
	section "Mason packages"
	local spec = require("lazy.core.config").plugins["mason-tool-installer.nvim"]
	if not spec then
		return warn "mason-tool-installer.nvim not in the plugin spec"
	end
	local opts = require("lazy.core.plugin").values(spec, "opts", false)
	local registry = require "mason-registry"
	local missing = {}
	for _, item in ipairs(opts.ensure_installed or {}) do
		local name = type(item) == "table" and item[1] or item
		if not registry.is_installed(name) then
			table.insert(missing, name)
		end
	end
	if #missing > 0 then
		warn("not installed: " .. table.concat(missing, ", ") .. " (run :MasonToolsInstall)")
	else
		pass(#opts.ensure_installed .. " ensure_installed packages present")
	end
end

local function check_executables()
	section "External tools"
	local tools = { "git", "lazygit", "node", "rg", "python3", "brain-rag", "sshfs" }
	for _, t in ipairs(tools) do
		if vim.fn.executable(t) == 1 then
			pass(t)
		else
			warn(t .. " not found on PATH")
		end
	end
end

local function check_messages()
	section "Messages"
	local msgs = vim.fn.execute "messages"
	local errs = {}
	for _, line in ipairs(vim.split(msgs, "\n")) do
		if line:match "^E%d+:" or line:match "[Ee]rror" or line:match "stack traceback" then
			table.insert(errs, line)
		end
	end
	for _, m in ipairs(notified) do
		table.insert(errs, m)
	end
	if #errs > 0 then
		fail("errors were reported", table.concat(errs, "\n"))
	else
		pass "no errors in :messages or vim.notify"
	end
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		-- Let scheduled startup work (mappings, deferred setups) run first
		vim.defer_fn(function()
			out("nvim smoke test (" .. tostring(vim.version()) .. ")")
			for _, step in ipairs { check_plugins, load_all, check_filetypes, check_mason, check_executables } do
				local ok, err = pcall(step)
				if not ok then
					fail("test step crashed", tostring(err))
				end
			end
			-- Give async work (LSP attach, linters) a moment to surface errors
			vim.wait(1500)
			check_messages()
			out(("\n%d failed, %d warnings"):format(#failures, #warnings))
			vim.cmd(#failures > 0 and "cquit 1" or "qall!")
		end, 500)
	end,
})
