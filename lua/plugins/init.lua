return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
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

-- null-ls

  {
    "jose-elias-alvarez/null-ls.nvim",
    -- ft = { "python" },
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
		require("configs.dap")
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
    requires = "MunifTanjim/nui.nvim",
    config = function()
      require("package-info").setup()
    end,
  },

  -- Jypescript and Javascrip
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" }, -- important!
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

  -- {
  --   "hiphish/rainbow-delimiters.nvim",
  -- config = function()
  -- 	require "configs.rainbow"
  -- end,
  -- },

  -- Auto-close and rename HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html" },
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- Treesitter itself
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require "configs.treesitter"
    end,
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
