-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

-- M.mappings = require "configs.mappings"

M.base46 = {
	theme = "rosepine-moon",

	hl_override = {
		-- Distinctly pink Visual selection.
		Visual = { bg = "#6e3855" },
		VisualNOS = { bg = "#6e3855" },
		-- Italic emphasis. @markup.italic is the newer capture, @text.emphasis
		-- the older one — set both so it works regardless of parser version.
		["@markup.italic"] = { italic = true },
		["@text.emphasis"] = { italic = true, fg = "yellow" },
		Comment = { italic = true },
		["@comment"] = { italic = true },
	},
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
--}

return M
