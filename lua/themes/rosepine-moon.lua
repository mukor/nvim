-- Rose Pine Moon for NvChad.
-- Canonical palette from https://rosepinetheme.com/palette/ (Moon variant).
-- Matches the colors used by other Rose Pine Moon integrations (Ghostty, etc.).

local M = {}

M.base_30 = {
	black = "#232136", -- bg
	darker_black = "#1d1b2c",
	white = "#e0def4",
	black2 = "#2a273f", -- surface
	one_bg = "#322f48",
	one_bg2 = "#363349",
	one_bg3 = "#393552", -- overlay
	grey = "#44415a", -- highlight med
	grey_fg = "#4d4a64",
	grey_fg2 = "#56526e", -- highlight high
	light_grey = "#6e6a86", -- muted
	red = "#eb6f92", -- love
	baby_pink = "#f5799c",
	pink = "#ff83a6",
	line = "#393552",
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
	statusline_bg = "#2a273f",
	lightbg = "#393552",
	pmenu_bg = "#c4a7e7",
	folder_bg = "#9ccfd8",
}

M.base_16 = {
	base00 = "#232136", -- bg
	base01 = "#2a273f", -- surface
	base02 = "#393552", -- overlay (default Visual bg)
	base03 = "#6e6a86", -- muted (comments)
	base04 = "#908caa", -- subtle
	base05 = "#e0def4", -- text
	base06 = "#e0def4",
	base07 = "#56526e", -- highlight high
	base08 = "#eb6f92", -- love
	base09 = "#f6c177", -- gold
	base0A = "#ea9a97", -- rose
	base0B = "#3e8fb0", -- pine
	base0C = "#9ccfd8", -- foam
	base0D = "#c4a7e7", -- iris
	base0E = "#f6c177", -- gold
	base0F = "#56526e",
}

M = require("base46").override_theme(M, "rosepine-moon")

M.type = "dark"

return M
