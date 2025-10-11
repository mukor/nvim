-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local util = require("lspconfig.util")

-- EXAMPLE
local servers = { "html", "cssls", "pyright", "ruff" }
local nvlsp = require "nvchad.configs.lspconfig"

-- NEW API: Configure LSP servers
for _, lsp in ipairs(servers) do
  vim.lsp.config[lsp] = {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- Pyright with dynamic Python path
vim.lsp.config.pyright = {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    python = {
      pythonPath = vim.fn.expand("$VIRTUAL_ENV") .. "/bin/python3",
      analysis = {
        extraPaths = {vim.fn.expand("$VIRTUAL_ENV") .. "/lib/python3.13/site-packages"},
      },
      formatting = {
        provider = "black",
        indent = "tab",
      },
    },
  },
}

-- Ruff configuration
vim.lsp.config.ruff = {
  on_attach = function(client, bufnr)
    -- Disable ruff's diagnostics, only use it for formatting
    client.server_capabilities.diagnosticProvider = false
    nvlsp.on_attach(client, bufnr)
  end,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}



-- Setup eslint with formatting on save
vim.lsp.config.eslint = {
  on_attach = function(client, bufnr)
    -- enable formatting on save
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true }),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
    -- use the default on_attach too
    nvlsp.on_attach(client, bufnr)
  end,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

-- Tailwind CSS
vim.lsp.config.tailwindcss = {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  filetypes = {
    "html",
    "css",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
}

-- NEW API: Enable all configured servers
local all_servers = vim.tbl_extend("force", servers, { "eslint", "tailwindcss" })
for _, lsp in ipairs(all_servers) do
  vim.lsp.enable(lsp)
end
