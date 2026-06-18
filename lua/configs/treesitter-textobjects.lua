-- nvim-treesitter-textobjects `main` branch: configured via its own setup(),
-- and keymaps call select_textobject directly (no auto-registered keymaps).

require("nvim-treesitter-textobjects").setup {
	select = {
		lookahead = true,
	},
}

local select = require("nvim-treesitter-textobjects.select")
local function map(lhs, obj)
	vim.keymap.set({ "x", "o" }, lhs, function()
		select.select_textobject(obj, "textobjects")
	end, { desc = "textobject " .. obj })
end

-- vaf / vif / vac / vic
map("af", "@function.outer")
map("if", "@function.inner")
map("ac", "@class.outer")
map("ic", "@class.inner")
