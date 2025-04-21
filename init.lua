vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- dynamically load the virtual env
-- vim.g.python3_host_prog = vim.fn.expand("$VIRTUAL_ENV") .. "/bin/python"

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- tabs instead of spaces
vim.opt.expandtab = false  -- Use actual tab characters
vim.opt.tabstop = 4        -- Set tab width to 4 spaces (change as needed)
vim.opt.shiftwidth = 4     -- Indentation width
vim.opt.softtabstop = 4    -- Makes backspace behave correctly

vim.filetype.add({
  extension = {
    jsx = "javascriptreact",
  },
})
