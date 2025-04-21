local configs = require("nvim-treesitter.configs")

configs.setup {
  ensure_installed = {
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
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
}
