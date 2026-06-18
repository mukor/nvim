-- nvim-treesitter `main` branch: no `.setup{}` and no `nvim-treesitter.configs`.
-- The plugin installs parsers; Neovim core does highlighting/indent/folds, which
-- we enable per-buffer with an autocmd.

local langs = {
	"lua",
	"vim",
	"vimdoc",
	"html",
	"css",
	"javascript",
	"typescript",
	"tsx",
	"json",
	"python",
	"markdown",
	"markdown_inline",
}

-- Fetch/compile any parsers not already present. Async; safe at startup.
require("nvim-treesitter").install(langs)

-- Enable treesitter highlighting (+ folds/indent) for these filetypes. This is
-- what the old `highlight = { enable = true }` did under the hood.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
	pattern = langs,
	callback = function()
		pcall(vim.treesitter.start)
		vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt_local.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
