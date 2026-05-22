local dap = require "dap"
local venv = require "utils.venv"

-- .vscode/launch.json is now auto-loaded on-demand by nvim-dap (see :help dap-providers).
-- If you need to map non-standard launch.json types to Python, register them via
-- require("dap.ext.vscode").type_to_filetypes instead.

-- Manually configure Python adapter
dap.adapters.python = {
	type = "executable",
	command = vim.fn.exepath "python3", -- fallback if no virtualenv
	args = { "-m", "debugpy.adapter" },
}

-- Fallback config if no launch.json is found
dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "FastAPI (backend/main.py)",
		program = "${workspaceFolder}/backend/main.py",
		args = { "--host", "127.0.0.1", "--port", "8000", "--reload" },
		cwd = "${workspaceFolder}/backend",
		pythonPath = function()
			return venv.python()
		end,
		env = {
			ENVIRONMENT = "development",
			PYTHONPATH = "${workspaceFolder}/backend",
		},
		console = "integratedTerminal",
		justMyCode = false,
	},
}
