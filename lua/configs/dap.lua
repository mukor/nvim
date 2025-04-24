local dap = require("dap")
local vscode = require("dap.ext.vscode")

-- Load launch.json if available
-- This reads .vscode/launch.json and maps `"type": "debugpy"` to Python
vscode.load_launchjs(nil, { python = { "debugpy" } })

-- Manually configure Python adapter
dap.adapters.python = {
  type = "executable",
  command = vim.fn.exepath("python3"), -- fallback if no virtualenv
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
      local venv_path = os.getenv("VIRTUAL_ENV")
      if venv_path then
        return venv_path .. "/bin/python"
      else
        return vim.fn.exepath("python3")
      end
    end,
    env = {
      ENVIRONMENT = "development",
      PYTHONPATH = "${workspaceFolder}/backend",
    },
    console = "integratedTerminal",
    justMyCode = false,
  },
}

