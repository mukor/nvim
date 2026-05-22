local lint = require "lint"
local venv = require "utils.venv"

lint.linters_by_ft = {
	python = { "mypy" },
}

-- Inject the workspace venv into mypy so it sees installed packages.
local mypy = lint.linters.mypy
local base_args = vim.deepcopy(mypy.args)
mypy.args = function()
	local args = { "--python-executable", venv.python() }
	vim.list_extend(args, base_args)
	return args
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
	group = vim.api.nvim_create_augroup("Lint", { clear = true }),
	callback = function()
		require("lint").try_lint()
	end,
})
