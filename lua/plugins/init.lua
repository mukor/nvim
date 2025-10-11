return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",
        "mypy",
        "ruff",
        "black",
        "debugpy",
        "eslint_d",
        "prettier",
        "typescript-language-server",
      },
    },
  },

  {
    "nvim-neotest/nvim-nio",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- none-ls (formerly null-ls)
  {
    "nvimtools/none-ls.nvim",  -- ✅ Updated
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      return require "configs.null-ls"
    end,
  },

  -- nvim dap ui
  {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- nvim dap
  {
    "mfussenegger/nvim-dap",
    config = function(_, opts)
      require "configs.dap"
      require("mappings").load_mappings "dap"
    end,
  },

  -- python dap (debugpy)
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function(_, opts)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
      require("mappings").load_mappings "dap_python"
    end,
  },

  -- LazyGit
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Claude Code
  {
    "greggh/claude-code.nvim",
    keys = { "<leader>cc" },
	cmd = "ClaudeCode",
	dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claude-code").setup({
        window = {
          position = "float",
          size = 20,
          enter_insert = true,
          hide_numbers = true,
          hide_signcolumn = true,
          float = {
            width = "80%",
            height = "80%",
            row = "center",
            col = "center",
            relative = "editor",
            border = "rounded",
          },
        },
        refresh = {
          enable = true,
          updatetime = 100,
          timer_interval = 1000,
          show_notifications = true,
        },
      })
      vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })
    end,
  },

  -- Tmux
  {
    "aserowy/tmux.nvim",
    config = function()
      require("tmux").setup {
        navigation = {
          enable_default_keybindings = true,
        },
      }
    end,
  },

  -- NPM package.json manager
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },  -- ✅ Fixed
    config = function()
      require("package-info").setup()
    end,
  },

  -- TypeScript and JavaScript
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        expose_as_code_action = "all",
        tsserver_plugins = {},
      },
    },
  },

  -- Rainbow parentheses
  {
    "hiphish/rainbow-delimiters.nvim",
    lazy = false,
    config = function()
      local rainbow_delimiters = require "rainbow-delimiters"
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
      }
    end,
  },

  -- Auto-close and rename HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html" },
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require "configs.treesitter"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
  },
}
