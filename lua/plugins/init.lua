-- Smart layout switcher for the Claude pane. Reuses the claude buffer in
-- place across layout changes so the WebSocket session survives.
--   * not visible           → open in requested orientation
--   * same orientation      → hide (simple_toggle, not close — process kept)
--   * horizontal ↔ vertical → wincmd J/L on the existing window
--   * → floating            → convert window via nvim_win_set_config
--   * floating → split      → nvim_win_set_config out of float, then wincmd
local function claude_open_in(layout, opts)
	local term = require("claudecode.terminal")
	local bufnr = term.get_active_terminal_bufnr()

	if bufnr == nil then
		term.open(opts)
		vim.g.claude_layout = layout
		return
	end

	if vim.g.claude_layout == layout then
		term.simple_toggle()
		return
	end

	local claude_win
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(w) == bufnr then
			claude_win = w
			break
		end
	end
	if not claude_win then
		return
	end

	local prev_win = vim.api.nvim_get_current_win()
	local cfg = vim.api.nvim_win_get_config(claude_win)
	local was_float = cfg.relative and cfg.relative ~= ""

	if layout == "floating" then
		local w = math.floor(vim.o.columns * 0.85)
		local h = math.floor(vim.o.lines * 0.85)
		vim.api.nvim_win_set_config(claude_win, {
			relative = "editor",
			width = w,
			height = h,
			row = math.floor((vim.o.lines - h) / 2),
			col = math.floor((vim.o.columns - w) / 2),
			border = "rounded",
		})
	else
		if was_float then
			vim.api.nvim_win_set_config(claude_win, { split = "below", win = -1 })
		end
		vim.api.nvim_set_current_win(claude_win)
		if layout == "horizontal" then
			vim.cmd("wincmd J")
			vim.api.nvim_win_set_height(claude_win, math.floor(vim.o.lines * 0.40))
		else
			vim.cmd("wincmd L")
			vim.api.nvim_win_set_width(claude_win, math.floor(vim.o.columns * 0.30))
		end
	end

	if prev_win ~= claude_win and vim.api.nvim_win_is_valid(prev_win) then
		vim.api.nvim_set_current_win(prev_win)
	end
	vim.g.claude_layout = layout
end

-- Layout definitions for the picker. Keep in sync with claude_open_in's branches.
local claude_layouts = {
	{ key = "horizontal", label = "Horizontal", opts = { snacks_win_opts = { position = "bottom", height = 0.40 } } },
	{ key = "vertical",   label = "Vertical",   opts = { snacks_win_opts = { position = "right",  width  = 0.30 } } },
	{ key = "floating",   label = "Floating",   opts = { snacks_win_opts = { position = "float",  width  = 0.85, height = 0.85, border = "rounded", backdrop = 60 } } },
}

-- Little floating-window picker for the Claude pane. j/k or h/l to move,
-- Enter to confirm, 1/2/3 for direct select, Esc/q to cancel. Each row
-- shows what will happen ("open" / "close" / "switch") for that orientation.
local function claude_picker()
	local term = require("claudecode.terminal")
	local visible = term.get_active_terminal_bufnr() ~= nil
	local current = visible and vim.g.claude_layout or nil

	local function action(key)
		if not visible then return "open" end
		if current == key then return "close" end
		return "switch"
	end

	local lines, max_label = {}, 0
	for _, l in ipairs(claude_layouts) do
		max_label = math.max(max_label, #l.label)
	end
	for i, l in ipairs(claude_layouts) do
		lines[i] = string.format(" %d. %-" .. max_label .. "s   [%s]", i, l.label, action(l.key))
	end

	local width = max_label + 16
	local height = #claude_layouts
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2) - 2,
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		border = "rounded",
		title = " Claude pane ",
		title_pos = "center",
		style = "minimal",
	})
	vim.wo[win].cursorline = true

	-- Start cursor on the currently-active layout (or row 1)
	local start_row = 1
	for i, l in ipairs(claude_layouts) do
		if l.key == current then start_row = i end
	end
	vim.api.nvim_win_set_cursor(win, { start_row, 0 })

	local function close_picker()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	local function pick(idx)
		local item = claude_layouts[idx]
		close_picker()
		if item then claude_open_in(item.key, item.opts) end
	end

	local function map(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, nowait = true })
	end
	map("j", "j")
	map("k", "k")
	map("h", "k")
	map("l", "j")
	map("<Down>", "j")
	map("<Up>", "k")
	map("<CR>", function() pick(vim.api.nvim_win_get_cursor(win)[1]) end)
	map("<Esc>", close_picker)
	map("q", close_picker)
	for i = 1, #claude_layouts do
		map(tostring(i), function() pick(i) end)
	end
end

return {
	{
		"stevearc/conform.nvim",
		-- event = 'BufWritePre', -- uncomment for format on save
		opts = require "configs.conform",
	},

	{
		"williamboman/mason.nvim",
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"lua-language-server",
				"stylua",
				"pyright",
				"ruff",
				"debugpy",
				"prettier",
				-- Kept for the tsserver binary it bundles; typescript-tools.nvim
				-- uses tsserver directly. Safe to drop if `typescript` lives in
				-- project node_modules or is globally installed via npm.
				"typescript-language-server",
			},
			auto_update = false,
			run_on_start = true,
		},
	},

	{
		"nvim-neotest/nvim-nio",
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			require "configs.lspconfig"
		end,
	},

	-- nvim dap ui
	{
		"rcarriga/nvim-dap-ui",
		dependencies = "mfussenegger/nvim-dap",
		config = function()
			local dap = require "dap"
			local dapui = require "dapui"
			dapui.setup()
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},

	-- nvim dap
	{
		"mfussenegger/nvim-dap",
		config = function(_, opts)
			require "configs.dap"
			require("mappings").load_mappings "dap"
		end,
	},

	-- python dap (debugpy)
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = {
			"mfussenegger/nvim-dap",
			"rcarriga/nvim-dap-ui",
		},
		config = function(_, opts)
			local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
			require("dap-python").setup(path)
			require("mappings").load_mappings "dap_python"
		end,
	},

	-- LazyGit
	{
		"kdheepak/lazygit.nvim",
		cmd = "LazyGit",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Claude Code — implements the same WebSocket/MCP protocol as the official
	-- VS Code / JetBrains extensions: selection sending, diff accept/reject,
	-- buffer/diagnostic context shared with Claude.
	-- Uses the snacks.nvim provider so the terminal can open as a bottom
	-- horizontal split (claudecode's native provider is vertical-only).
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		opts = {
			terminal = {
				provider = "snacks",
				snacks_win_opts = {
					position = "bottom",
					height = 0.40,
				},
			},
		},
		keys = {
			{ "<leader>cc", claude_picker, desc = "Claude pane picker (h/v/floating)" },
			{ "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
			{ "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
	},

	-- Tmux
	{
		"aserowy/tmux.nvim",
		config = function()
			require("tmux").setup {
				navigation = {
					enable_default_keybindings = true,
				},
			}
		end,
	},

	-- NPM package.json manager
	{
		"vuki656/package-info.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		config = function()
			require("package-info").setup()
		end,
	},

	-- TypeScript and JavaScript
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		opts = {
			settings = {
				separate_diagnostic_server = true,
				publish_diagnostic_on = "insert_leave",
				expose_as_code_action = "all",
				tsserver_plugins = {},
			},
		},
	},

	-- Rainbow parentheses
	{
		"hiphish/rainbow-delimiters.nvim",
		lazy = false,
		config = function()
			require "configs.rainbow"
		end,
	},

	-- Auto-close and rename HTML/JSX tags
	{
		"windwp/nvim-ts-autotag",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html" },
		event = "InsertEnter",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	-- Treesitter — pinned to the classic `master` branch architecture.
	-- The new `main` branch requires Neovim 0.12+ and uses a different API.
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		config = function()
			require "configs.treesitter"
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "master",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
	},

	-- Telekasten (Zettelkasten/note-taking)
	{
		"nvim-telekasten/telekasten.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "renerocksai/calendar-vim" },
		cmd = "Telekasten",
		ft = "markdown",
		keys = {
			"<leader>z",
			"<leader>zf",
			"<leader>zg",
			"<leader>zn",
			"<leader>zd",
			"<leader>zt",
			"<leader>zb",
			"<leader>zz",
			"<leader>zc",
			"<leader>zI",
		},
		config = function()
			require("telekasten").setup {
				home = vim.fn.expand "~/notes",
				media_previewer = "viu-previewer",
			}
			vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>", { desc = "Telekasten panel" })
			vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>", { desc = "Find notes" })
			vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>", { desc = "Search notes" })
			vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>", { desc = "New note" })
			vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>", { desc = "Daily note" })
			vim.keymap.set("n", "<leader>zt", "<cmd>Telekasten toggle_todo<CR>", { desc = "Toggle todo" })
			vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>", { desc = "Show backlinks" })
			vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>", { desc = "Follow link" })
			vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>", { desc = "Show calendar" })
			vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>", { desc = "Insert image link" })
		end,
	},

	-- Telescope media files (image preview for Telekasten)
	{
		"nvim-telescope/telescope-media-files.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("telescope").setup {
				extensions = {
					media_files = {
						filetypes = { "png", "jpg", "jpeg", "gif", "webp", "mp4", "pdf" },
						find_cmd = "rg",
						img_previewer = "viu",
					},
				},
			}
			require("telescope").load_extension "media_files"
		end,
	},

	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = "markdown",
		build = "cd app && npm install",
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle markdown preview" },
		},
	},

	-- Telescope symbols (emoji and symbol picker)
	{
		"nvim-telescope/telescope-symbols.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		keys = {
			{ "<leader>se", "<cmd>Telescope symbols<CR>", desc = "Insert symbol/emoji" },
		},
	},

	-- Remote SSHFS (edit remote files via SSH)
	{
		"nosduco/remote-sshfs.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		cmd = {
			"RemoteSSHFSConnect",
			"RemoteSSHFSDisconnect",
			"RemoteSSHFSEdit",
			"RemoteSSHFSFindFiles",
			"RemoteSSHFSLiveGrep",
		},
		keys = {
			{ "<leader>rc", "<cmd>RemoteSSHFSConnect<CR>", desc = "Connect to remote host" },
			{ "<leader>rd", "<cmd>RemoteSSHFSDisconnect<CR>", desc = "Disconnect from remote" },
			{ "<leader>re", "<cmd>RemoteSSHFSEdit<CR>", desc = "Edit remote ssh config" },
			{ "<leader>rf", "<cmd>RemoteSSHFSFindFiles<CR>", desc = "Find files on remote" },
			{ "<leader>rg", "<cmd>RemoteSSHFSLiveGrep<CR>", desc = "Grep on remote" },
		},
		config = function()
			require("remote-sshfs").setup {}
			require("telescope").load_extension "remote-sshfs"
		end,
	},

	-- Gitsigns keymaps (gitsigns itself is already shipped by NvChad)
	{
		"lewis6991/gitsigns.nvim",
		keys = {
			{
				"]h",
				function()
					require("gitsigns").nav_hunk "next"
				end,
				desc = "Next git hunk",
			},
			{
				"[h",
				function()
					require("gitsigns").nav_hunk "prev"
				end,
				desc = "Prev git hunk",
			},
			{
				"<leader>hs",
				function()
					require("gitsigns").stage_hunk()
				end,
				desc = "Stage hunk",
			},
			{
				"<leader>hr",
				function()
					require("gitsigns").reset_hunk()
				end,
				desc = "Reset hunk",
			},
			{
				"<leader>hp",
				function()
					require("gitsigns").preview_hunk()
				end,
				desc = "Preview hunk",
			},
			{
				"<leader>hb",
				function()
					require("gitsigns").blame_line { full = true }
				end,
				desc = "Blame line",
			},
			{
				"<leader>hd",
				function()
					require("gitsigns").diffthis()
				end,
				desc = "Diff this",
			},
		},
	},

	-- mini.move — grab a Visual selection (or the current line) and shove it
	-- around with Alt+hjkl. Left/right move by a character, up/down by a line
	-- (auto-reindents). Alt+hjkl is free here: NvChad uses Ctrl+hjkl for window
	-- nav, and nothing else binds Meta+hjkl.
	{
		"echasnovski/mini.move",
		version = false,
		keys = {
			{ "<M-h>", mode = { "n", "v" } },
			{ "<M-j>", mode = { "n", "v" } },
			{ "<M-k>", mode = { "n", "v" } },
			{ "<M-l>", mode = { "n", "v" } },
		},
		opts = {
			mappings = {
				-- Visual mode
				left = "<M-h>",
				right = "<M-l>",
				down = "<M-j>",
				up = "<M-k>",
				-- Normal mode (move the current line)
				line_left = "<M-h>",
				line_right = "<M-l>",
				line_down = "<M-j>",
				line_up = "<M-k>",
			},
		},
	},

	-- mini.surround — wrap/change/delete surrounding chars. In Visual mode,
	-- select text and press `sa` then the char ( ) " ' * etc. In Normal mode
	-- `sa` takes a motion (e.g. `saiw"` surrounds the inner word with quotes).
	-- `sd"` deletes surrounding quotes, `sr"'` replaces " with '.
	{
		"echasnovski/mini.surround",
		version = false,
		keys = {
			{ "sa", mode = { "n", "v" } },
			{ "sd", mode = "n" },
			{ "sr", mode = "n" },
			{ "sf", mode = "n" },
			{ "sF", mode = "n" },
			{ "sh", mode = "n" },
			{ "sn", mode = "n" },
		},
		opts = {
			mappings = {
				add = "sa", -- Add surrounding (Normal motion + Visual selection)
				delete = "sd", -- Delete surrounding
				replace = "sr", -- Replace surrounding
				find = "sf", -- Find surrounding (to the right)
				find_left = "sF", -- Find surrounding (to the left)
				highlight = "sh", -- Highlight surrounding
				update_n_lines = "sn", -- Update `n_lines` search range
			},
		},
	},

	-- Brain Rag Plugin
	{
		dir = "~/dev/brain-rag.nvim",
		dependencies = { "hrsh7th/nvim-cmp", "L3MON4D3/LuaSnip" },
		ft = "markdown",
		config = function()
			require("brain-rag").setup {
				tags = {
					brain_rag_cmd = "/home/spencer/dev/brain-rag/.venv/bin/brain-rag",
				},
			}
		end,
	},
}
