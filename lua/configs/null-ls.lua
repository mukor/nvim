local null_ls = require("null-ls")

local python_path = vim.fn.expand("$VIRTUAL_ENV") .. "/bin/python"

local opts = {
  sources = {
    null_ls.builtins.diagnostics.mypy.with({
      extra_args = { "--python-executable", python_path },
    }),
    null_ls.builtins.diagnostics.ruff,
    null_ls.builtins.formatting.black,
  },
}
return opts

