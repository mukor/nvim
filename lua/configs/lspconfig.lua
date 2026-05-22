-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"
local venv = require "utils.venv"

-- Base configuration for all servers
local base_config = {
	on_attach = nvlsp.on_attach,
	on_init = nvlsp.on_init,
	capabilities = nvlsp.capabilities,
}

-- Configure basic servers using new vim.lsp.config API
local servers = { "html", "cssls" }

for _, server in ipairs(servers) do
	vim.lsp.config[server] = base_config
end

-- Pyright — resolve interpreter per-workspace at LSP init time.
-- Order: $VIRTUAL_ENV → <root>/.venv/bin/python → system python3.
-- Force UTF-8 position encoding so pyright agrees with ruff (which is UTF-8 only).
vim.lsp.config.pyright = {
	on_attach = nvlsp.on_attach,
	on_init = nvlsp.on_init,
	capabilities = vim.tbl_deep_extend("force", nvlsp.capabilities, {
		general = { positionEncodings = { "utf-8" } },
	}),
	before_init = function(_, config)
		config.settings = config.settings or {}
		config.settings.python = config.settings.python or {}
		config.settings.python.pythonPath = venv.python(config.root_dir)
	end,
}

-- Ruff: linting via LSP diagnostics. Formatting is handled by conform (ruff_format).
-- Pyright handles type checking; defer hover to pyright to avoid duplicate popups.
vim.lsp.config.ruff = {
	on_attach = function(client, bufnr)
		client.server_capabilities.hoverProvider = false
		nvlsp.on_attach(client, bufnr)
	end,
	on_init = nvlsp.on_init,
	capabilities = nvlsp.capabilities,
}

-- Setup eslint with formatting on save
vim.lsp.config.eslint = {
	on_attach = function(client, bufnr)
		-- enable formatting on save
		if client.server_capabilities.documentFormattingProvider then
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true }),
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format { bufnr = bufnr }
				end,
			})
		end
		-- use the default on_attach too
		nvlsp.on_attach(client, bufnr)
	end,
	on_init = nvlsp.on_init,
	capabilities = nvlsp.capabilities,
}

-- Tailwind CSS
vim.lsp.config.tailwindcss = {
	on_attach = nvlsp.on_attach,
	on_init = nvlsp.on_init,
	capabilities = nvlsp.capabilities,
	filetypes = {
		"html",
		"css",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
}

-- NEW API: Enable all configured servers
local all_servers = vim.tbl_extend("force", servers, { "pyright", "ruff", "eslint", "tailwindcss" })
for _, lsp in ipairs(all_servers) do
	vim.lsp.enable(lsp)
end
