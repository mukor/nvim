local dap = require("dap")

dap.adapters.python = {
  type = "executable",
  command = vim.fn.exepath("python3"),  -- Use system Python
  args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch FastAPI",
    program = "${workspaceFolder}/main.py",  -- Change to your main FastAPI script
    args = { "--host", "172.27.139.9", "--port", "8000", "--reload" },
    pythonPath = function()
      return vim.fn.exepath("python3")  -- Ensures the correct Python is used
    end,
  },
}
