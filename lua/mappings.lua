-- require "nvchad.mappings"
--
-- -- add yours here
--
-- local map = vim.keymap.set
--
-- map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")
--
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")


require "nvchad.mappings"

local M = {}


--require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

--lazygit
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

M.load_mappings = function(mode)
  local keymaps = {
    dap = {
      ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>", "Toggle Breakpoint" },
      ["<leader>dc"] = { "<cmd> DapContinue <CR>", "Continue Deubgging"}
    },
    dap_python = {
      ["<leader>dpr"] = {
        function()
          require('dap-python').test_method()
        end,
        "Run Python test method"
      }
    }
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
