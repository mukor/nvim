local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_organize_imports", "ruff_format" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		markdown = { "prettier" },
		yaml = { "prettier" },
	},

	-- To enable format-on-save, uncomment:
	-- format_on_save = {
	--   timeout_ms = 1000,
	--   lsp_fallback = true,
	-- },
}

return options
