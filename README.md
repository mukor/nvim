# NvChad Neovim Configuration

Personal Neovim configuration built on **NvChad v2.5** with comprehensive support for Python, JavaScript/TypeScript, and modern web development.

## Features

### Language Support
- **Python**: Pyright, mypy, ruff, black, debugpy
- **JavaScript/TypeScript**: TypeScript tools, ESLint, Prettier
- **Web**: HTML, CSS, Tailwind CSS with IntelliSense
- **Auto-close & rename** HTML/JSX tags

### Development Tools
- **LSP**: Full language server support with auto-completion
- **Debugging**: DAP integration with VS Code-style keybindings (F5-F12)
- **Git**: LazyGit integration
- **AI**: Claude Code assistant (`Space c c`)
- **Formatting**: Auto-format on save with black, prettier, eslint
- **Linting**: mypy, ruff, eslint_d

### UI Enhancements
- **Rainbow delimiters**: Color-coded brackets/parentheses
- **Treesitter**: Advanced syntax highlighting and text objects
- **Tmux integration**: Seamless pane navigation
- **11 themes** available via NvChad

## Prerequisites

- **Neovim** 0.11+
- **Lazygit** (for git integration)
- **Node.js** (for JS/TS language servers) - https://nodejs.org/en/download
- **Go** (for some tools)
- **Python** virtual environment with project dependencies

## Installation

1. Clone this repository to your Neovim config directory:
```bash
git clone https://github.com/mukor/nvim.git ~/.config/nvim
```

2. Open Neovim - plugins will automatically install:
```bash
nvim
```

3. Wait for lazy.nvim to install all plugins

4. Wait for Mason to install language servers and tools

5. Verify installation:
```vim
:checkhealth
```

## Quick Start

### Python Development
```bash
# Activate virtual environment
source venv/bin/activate

# Open Neovim
nvim .
```

### Key Mappings

| Action | Keybinding |
|--------|-----------|
| Command mode | `;` |
| Exit insert mode | `jk` |
| LazyGit | `Space g g` |
| Claude Code | `Space c c` |
| Toggle breakpoint | `Space d b` or `F9` |
| Start debugging | `Space d c` or `F5` |
| Step over | `Space d o` or `F10` |
| Step into | `Space d i` or `F11` |
| Step out | `Space d u` or `F12` |

See [CONFIG_SUMMARY.md](CONFIG_SUMMARY.md) for complete keybinding list.

## Core Plugins

### LSP & Tools
- **mason.nvim** - Package manager for LSP servers
- **mason-tool-installer.nvim** - Auto-installs tools
- **mason-null-ls.nvim** - Bridges Mason and none-ls
- **nvim-lspconfig** - LSP configurations

### Language Servers
- **pyright** - Python type checking
- **ruff** - Python linting
- **typescript-language-server** - JS/TS support
- **eslint** - JavaScript/TypeScript linting
- **tailwindcss** - Tailwind CSS IntelliSense

### Linting & Formatting
- **none-ls.nvim** (formerly null-ls) - Linting/formatting integration
- **conform.nvim** - Format orchestration
- **black** - Python formatter
- **prettier** - JS/TS/HTML/CSS formatter
- **mypy** - Python type checker

### Debugging
- **nvim-dap** - Debug Adapter Protocol
- **nvim-dap-ui** - Debugging UI
- **nvim-dap-python** - Python debugging
- **debugpy** - Python debug adapter

### Development
- **lazygit.nvim** - Git interface
- **claude-code.nvim** - AI assistant
- **tmux.nvim** - Tmux integration
- **package-info.nvim** - npm package manager

### Syntax & UI
- **nvim-treesitter** - Advanced syntax highlighting
- **rainbow-delimiters.nvim** - Colored brackets
- **nvim-ts-autotag** - Auto-close HTML/JSX tags

## Configuration Files

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── chadrc.lua          # NvChad theme (onedark)
│   ├── options.lua         # Editor options
│   ├── mappings.lua        # Keybindings
│   ├── configs/            # Plugin configurations
│   │   ├── lspconfig.lua
│   │   ├── null-ls.lua
│   │   ├── dap.lua
│   │   └── ...
│   └── plugins/init.lua    # Plugin declarations
└── README.md               # This file
```

## Documentation

- **[CONFIG_SUMMARY.md](CONFIG_SUMMARY.md)** - Complete configuration reference with all plugins, keybindings, and workflows
- **[CLAUDE.md](CLAUDE.md)** - Architecture guide for AI assistants

## Compatibility

- ✅ Neovim 0.11+ (uses modern `vim.lsp.config` API)
- ✅ NvChad v2.5
- ✅ Supports Python 3.13 (paths configurable)
- ✅ Virtual environment detection via `$VIRTUAL_ENV`

## Troubleshooting

### LSP not working
```vim
:LspInfo
:checkhealth lsp
```

### Tools not found
```vim
:Mason
:checkhealth mason
```

### Python debugging issues
- Ensure `$VIRTUAL_ENV` is set
- Check debugpy is installed: `:Mason`

## Contributing

This is a personal configuration, but feel free to fork and adapt for your needs.

## License

See [LICENSE](LICENSE) file.

---

*Built with NvChad v2.5*
