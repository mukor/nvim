require "nvchad.mappings"

local M = {}

-- Simple keymap utility
local map = vim.keymap.set

-- General
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- LazyGit
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit" })

-- Save (optional if you want)
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "Save file" })

-- Modular keymaps per "mode"
M.load_mappings = function(mode)
  local keymaps = {
    dap = {
      -- Leader mappings
      ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>", "Toggle Breakpoint" },
      ["<leader>dc"] = { "<cmd> DapContinue <CR>", "Continue Debugging" },
      ["<leader>do"] = { "<cmd> DapStepOver <CR>", "Step Over" },
      ["<leader>di"] = { "<cmd> DapStepInto <CR>", "Step Into" },
      ["<leader>du"] = { "<cmd> DapStepOut <CR>", "Step Out" },
      ["<leader>dr"] = { "<cmd> DapRestartFrame <CR>", "Restart Frame" },
      ["<leader>dl"] = { "<cmd> DapRunLast <CR>", "Run Last Debug Session" },
      ["<leader>ds"] = { "<cmd> DapTerminate <CR>", "Stop Debugger" },
      ["<leader>dR"] = { "<cmd> DapToggleRepl <CR>", "Toggle DAP REPL" },

      -- Function keys (VS Code style)
      ["<F5>"] = { "<cmd> DapContinue <CR>", "Continue Debugging (F5)" },
      ["<F9>"] = { "<cmd> DapToggleBreakpoint <CR>", "Toggle Breakpoint (F9)" },
      ["<F10>"] = { "<cmd> DapStepOver <CR>", "Step Over (F10)" },
      ["<F11>"] = { "<cmd> DapStepInto <CR>", "Step Into (F11)" },
      ["<F12>"] = { "<cmd> DapStepOut <CR>", "Step Out (F12)" },
    },
    dap_python = {
      ["<leader>dpr"] = {
        function()
          require("dap-python").test_method()
        end,
        "Run Python test method",
      },
    },
  }

  if keymaps[mode] then
    for key, map in pairs(keymaps[mode]) do
      vim.keymap.set("n", key, map[1], { desc = map[2] })
    end
  else
    vim.notify("No mappings found for mode: " .. mode, vim.log.levels.WARN)
  end
end

return M
