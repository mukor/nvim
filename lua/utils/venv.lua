local M = {}

function M.python(root)
	if vim.env.VIRTUAL_ENV then
		local p = vim.env.VIRTUAL_ENV .. "/bin/python"
		if vim.fn.executable(p) == 1 then
			return p
		end
	end

	root = root or vim.fn.getcwd()
	local p = root .. "/.venv/bin/python"
	if vim.fn.executable(p) == 1 then
		return p
	end

	return vim.fn.exepath "python3"
end

return M
