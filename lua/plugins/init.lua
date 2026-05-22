return {
	{
		"stevearc/conform.nvim",
		-- event = 'BufWritePre', -- uncomment for format on save
		opts = require "configs.conform",
	},

	{
		"williamboman/mason.nvim",
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"lua-language-server",
				"stylua",
				"pyright",
				"ruff",
				"mypy",
				"debugpy",
				"prettier",
				-- Kept for the tsserver binary it bundles; typescript-tools.nvim
				-- uses tsserver directly. Safe to drop if `typescript` lives in
				-- project node_modules or is globally installed via npm.
				"typescript-language-server",
			},
			auto_update = false,
			run_on_start = true,
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

	-- Linters (mypy etc.) — formatters live in conform, LSP diagnostics live in pyright/ruff
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "InsertLeave" },
		config = function()
			require "configs.lint"
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

	-- Claude Code — implements the same WebSocket/MCP protocol as the official
	-- VS Code / JetBrains extensions: selection sending, diff accept/reject,
	-- buffer/diagnostic context shared with Claude.
	{
		"coder/claudecode.nvim",
		config = true,
		keys = {
			{ "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
			{ "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
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
		dependencies = { "MunifTanjim/nui.nvim" },
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
			require "configs.rainbow"
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

	-- Treesitter — pinned to the classic `master` branch architecture.
	-- The new `main` branch requires Neovim 0.12+ and uses a different API.
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		config = function()
			require "configs.treesitter"
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "master",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
	},

	-- Telekasten (Zettelkasten/note-taking)
	{
		"nvim-telekasten/telekasten.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "renerocksai/calendar-vim" },
		cmd = "Telekasten",
		ft = "markdown",
		keys = {
			"<leader>z",
			"<leader>zf",
			"<leader>zg",
			"<leader>zn",
			"<leader>zd",
			"<leader>zt",
			"<leader>zb",
			"<leader>zz",
			"<leader>zc",
			"<leader>zI",
		},
		config = function()
			require("telekasten").setup {
				home = vim.fn.expand "~/notes",
				media_previewer = "viu-previewer",
			}
			vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>", { desc = "Telekasten panel" })
			vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>", { desc = "Find notes" })
			vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>", { desc = "Search notes" })
			vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>", { desc = "New note" })
			vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>", { desc = "Daily note" })
			vim.keymap.set("n", "<leader>zt", "<cmd>Telekasten toggle_todo<CR>", { desc = "Toggle todo" })
			vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>", { desc = "Show backlinks" })
			vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>", { desc = "Follow link" })
			vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>", { desc = "Show calendar" })
			vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>", { desc = "Insert image link" })
		end,
	},

	-- Telescope media files (image preview for Telekasten)
	{
		"nvim-telescope/telescope-media-files.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("telescope").setup {
				extensions = {
					media_files = {
						filetypes = { "png", "jpg", "jpeg", "gif", "webp", "mp4", "pdf" },
						find_cmd = "rg",
						img_previewer = "viu",
					},
				},
			}
			require("telescope").load_extension "media_files"
		end,
	},

	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = "markdown",
		build = "cd app && npm install",
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle markdown preview" },
		},
	},

	-- Telescope symbols (emoji and symbol picker)
	{
		"nvim-telescope/telescope-symbols.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		keys = {
			{ "<leader>se", "<cmd>Telescope symbols<CR>", desc = "Insert symbol/emoji" },
		},
	},

	-- Remote SSHFS (edit remote files via SSH)
	{
		"nosduco/remote-sshfs.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		cmd = {
			"RemoteSSHFSConnect",
			"RemoteSSHFSDisconnect",
			"RemoteSSHFSEdit",
			"RemoteSSHFSFindFiles",
			"RemoteSSHFSLiveGrep",
		},
		keys = {
			{ "<leader>rc", "<cmd>RemoteSSHFSConnect<CR>", desc = "Connect to remote host" },
			{ "<leader>rd", "<cmd>RemoteSSHFSDisconnect<CR>", desc = "Disconnect from remote" },
			{ "<leader>re", "<cmd>RemoteSSHFSEdit<CR>", desc = "Edit remote ssh config" },
			{ "<leader>rf", "<cmd>RemoteSSHFSFindFiles<CR>", desc = "Find files on remote" },
			{ "<leader>rg", "<cmd>RemoteSSHFSLiveGrep<CR>", desc = "Grep on remote" },
		},
		config = function()
			require("remote-sshfs").setup {}
			require("telescope").load_extension "remote-sshfs"
		end,
	},

	-- Gitsigns keymaps (gitsigns itself is already shipped by NvChad)
	{
		"lewis6991/gitsigns.nvim",
		keys = {
			{
				"]h",
				function()
					require("gitsigns").nav_hunk "next"
				end,
				desc = "Next git hunk",
			},
			{
				"[h",
				function()
					require("gitsigns").nav_hunk "prev"
				end,
				desc = "Prev git hunk",
			},
			{
				"<leader>hs",
				function()
					require("gitsigns").stage_hunk()
				end,
				desc = "Stage hunk",
			},
			{
				"<leader>hr",
				function()
					require("gitsigns").reset_hunk()
				end,
				desc = "Reset hunk",
			},
			{
				"<leader>hp",
				function()
					require("gitsigns").preview_hunk()
				end,
				desc = "Preview hunk",
			},
			{
				"<leader>hb",
				function()
					require("gitsigns").blame_line { full = true }
				end,
				desc = "Blame line",
			},
			{
				"<leader>hd",
				function()
					require("gitsigns").diffthis()
				end,
				desc = "Diff this",
			},
		},
	},

	-- Brain Rag Plugin
	{
		dir = "~/dev/brain-rag.nvim",
		dependencies = { "hrsh7th/nvim-cmp", "L3MON4D3/LuaSnip" },
		ft = "markdown",
		config = function()
			require("brain-rag").setup {
				tags = {
					brain_rag_cmd = "/home/spencer/dev/brain-rag/.venv/bin/brain-rag",
				},
			}
		end,
	},
}
