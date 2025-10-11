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
  -- ✨ Add this block to enable vaf / vif / vac / vic
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
}

