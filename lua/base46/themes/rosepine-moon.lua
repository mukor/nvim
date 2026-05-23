-- Rose Pine Moon variant for NvChad.
-- Palette derived from https://rosepinetheme.com/palette/ (Moon),
-- warmed slightly toward rose for a softer feel against the dark base.

local M = {}

M.base_30 = {
	black = "#2a1f30", -- bg
	darker_black = "#221823",
	white = "#e0def4",
	black2 = "#322438", -- surface
	one_bg = "#382a3f",
	one_bg2 = "#3e3046",
	one_bg3 = "#4a3a52", -- overlay
	grey = "#534159", -- highlight med
	grey_fg = "#5d4863",
	grey_fg2 = "#6b5571", -- highlight high
	light_grey = "#7a6884", -- muted
	red = "#eb6f92", -- love
	baby_pink = "#f5799c",
	pink = "#ff83a6",
	line = "#4a3a52",
	green = "#abe9b3",
	vibrant_green = "#b5f3bd",
	nord_blue = "#86b9c2",
	blue = "#3e8fb0", -- pine
	yellow = "#f6c177", -- gold
	sun = "#fec97f",
	purple = "#c4a7e7", -- iris
	dark_purple = "#bb9ede",
	teal = "#9ccfd8", -- foam
	orange = "#ea9a97", -- rose
	cyan = "#9ccfd8",
	statusline_bg = "#322438",
	lightbg = "#4a3a52",
	pmenu_bg = "#c4a7e7",
	folder_bg = "#9ccfd8",
}

M.base_16 = {
	base00 = "#2a1f30",
	base01 = "#322438",
	base02 = "#4a3a52",
	base03 = "#7a6884",
	base04 = "#908caa",
	base05 = "#e0def4",
	base06 = "#e0def4",
	base07 = "#6b5571",
	base08 = "#eb6f92", -- love
	base09 = "#f6c177", -- gold
	base0A = "#ea9a97", -- rose
	base0B = "#3e8fb0", -- pine
	base0C = "#9ccfd8", -- foam
	base0D = "#c4a7e7", -- iris
	base0E = "#f6c177",
	base0F = "#6b5571",
}

M = require("base46").override_theme(M, "rosepine-moon")

M.type = "dark"

return M
