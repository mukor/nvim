local null_ls = require("null-ls")

local util = require("lspconfig.util") -- we use this to find project root

local python_path = vim.fn.expand("$VIRTUAL_ENV") .. "/bin/python"

-- Helper: detect Node.js project
-- local function is_node_project()
--   local root = util.root_pattern("package.json", "node_modules")(vim.fn.getcwd())
--   return root ~= nil
-- end

local opts = {
	sources = {
		-- python 
		null_ls.builtins.diagnostics.mypy.with({
			extra_args = { "--python-executable", python_path },
		}),
		null_ls.builtins.diagnostics.ruff,
		null_ls.builtins.formatting.black,

		-- node.js 
		null_ls.builtins.formatting.prettier,   -- Prettier formatter
		null_ls.builtins.diagnostics.eslint_d,  -- ESLint diagnostics
		-- JavaScript / TypeScript (only if node project)
		-- is_node_project() and null_ls.builtins.formatting.prettier or nil,
		-- is_node_project() and null_ls.builtins.diagnostics.eslint_d or nil,
	},
}
return opts

