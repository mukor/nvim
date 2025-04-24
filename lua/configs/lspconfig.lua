-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local util = require("lspconfig.util")

-- -- sets MYPYPATH to $VIRTUAL_ENV/lib/python3.10/site-packages
-- local venv_path = os.getenv("VIRTUAL_ENV")
-- if venv_path then
--   vim.env.MYPYPATH = venv_path .. "/lib/python3.10/site-packages"
-- end


-- EXAMPLE
local servers = { "html", "cssls", "pyright", "ruff" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- --Function to the Python path dynamically
-- local function get_python_path(workspace)
--   -- Use activated virtualenv if available
--   if os.getenv("VIRTUAL_ENV") then
--     return os.getenv("VIRTUAL_ENV") .. "/bin/python"
--   end
--
--   -- Find and use `venv` inside the workspace if it exists
--   local match = util.path.join(workspace, "venv", "bin", "python")
--   if util.path.exists(match) then
--     return match
--   end
--
--   -- Fallback to system Python
--   return "python3"
-- end

-- -- Setup Pyright with dynamic Python path
-- require("lspconfig").pyright.setup({
--   before_init = function(_, config)
--     config.settings.python.pythonPath = get_python_path(config.root_dir)
--     -- force pyright to look at the site pakages
--     if os.getenv("VIRTUAL_ENV") then
--       config.settings.python.extraPaths = os.getenv("VIRTUAL_ENV") .. "/lib/python3.10/site-pakages"
--     end
--   end
--   })


lspconfig.pyright.setup({
  settings = {
    python = {
      pythonPath = vim.fn.expand("$VIRTUAL_ENV") .. "/bin/python3",
      analysis = {
        extraPaths = {vim.fn.expand("$VIRTUAL_ENV") .. "/lib/python3.13/site-packages"},
      },
      formatting ={
        provider = "black",
        indent = "tab",
      },
    },
  },
})

-- if venv_path then
--   require("lspconfig").pyright.setup({
--     settings = {
--       python = {
--         analysis = {
--           extraPaths = { venv_path .. "/lib/python3.10/site-packages" },
--         },
--       },
--     },
--   })
-- end

-- Setup eslint
lspconfig.eslint.setup({
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
})

lspconfig.tailwindcss.setup ({
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
})

-- configuring single server, example: typescript
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }
