-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

-- Base configuration for all servers
local base_config = {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

-- Configure servers using new vim.lsp.config API
local servers = { "html", "cssls", "ruff" }

for _, server in ipairs(servers) do
  vim.lsp.config(server, base_config)
end

-- Pyright with custom settings
vim.lsp.config.pyright = vim.tbl_deep_extend("force", base_config, {
  settings = {
    python = {
      pythonPath = vim.fn.expand("$VIRTUAL_ENV") .. "/bin/python",
      analysis = {
        extraPaths = { vim.fn.expand("$VIRTUAL_ENV") .. "/lib/python3.10/site-packages" },
      },
      formatting = {
        provider = "black",
        indent = "tab",
      },
    },
  },
})
