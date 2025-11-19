# NvChad Neovim Configuration Summary

## Overview

This is a Neovim configuration built on **NvChad v2.5** with extensive support for:
- Python development (LSP, debugging, linting, formatting)
- JavaScript/TypeScript/React development
- Tailwind CSS
- Git integration
- Enhanced debugging with DAP
- AI assistance via Claude Code

**Neovim Version**: 0.11+
**Plugin Manager**: lazy.nvim
**Leader Key**: `Space`

---

## Plugins

### Core Framework
- **NvChad** (v2.5) - Base framework providing UI, themes, and default configurations
- **lazy.nvim** - Modern plugin manager with lazy loading

### Language Servers & Tools Management
- **mason.nvim** - Package manager for LSP servers, formatters, linters
- **mason-tool-installer.nvim** - Automatically installs configured tools on startup
- **mason-null-ls.nvim** - Bridges Mason and none-ls for automatic tool registration
- **nvim-lspconfig** - Quickstart configs for LSP servers

### LSP Servers Configured
- **pyright** - Python type checking and IntelliSense
- **ruff** - Fast Python linter (diagnostics disabled, formatting only)
- **html** - HTML language server
- **cssls** - CSS language server
- **eslint** - JavaScript/TypeScript linting with auto-fix on save
- **tailwindcss** - Tailwind CSS IntelliSense
- **typescript-language-server** - TypeScript/JavaScript language support

### Linting & Formatting
- **none-ls.nvim** (formerly null-ls) - Injects linting/formatting into LSP workflow
  - **mypy** - Python static type checker
  - **ruff** - Python linter
  - **black** - Python code formatter
  - **eslint_d** - Fast ESLint daemon for JS/TS
  - **prettier** - Code formatter for JS/TS/HTML/CSS/JSON
- **conform.nvim** - Format orchestration (currently configured for stylua)

### Debugging (DAP)
- **nvim-dap** - Debug Adapter Protocol client
- **nvim-dap-ui** - UI for nvim-dap with automatic open/close
- **nvim-dap-python** - Python debugging with debugpy
- **nvim-nio** - Async I/O library (required by dap-ui)

### Syntax & Parsing
- **nvim-treesitter** - Advanced syntax highlighting and code understanding
  - Parsers installed: lua, vim, vimdoc, html, css, javascript, typescript, tsx, json, python
- **nvim-treesitter-textobjects** - Text objects based on treesitter (e.g., `vaf` for function, `vic` for inner class)

### UI Enhancements
- **rainbow-delimiters.nvim** - Color-coded parentheses, brackets, and braces
- **nvim-ts-autotag** - Auto-close and auto-rename HTML/JSX tags

### Git Integration
- **lazygit.nvim** - Terminal UI for Git (integrates lazygit inside Neovim)

### AI Assistance
- **claude-code.nvim** - Claude Code AI assistant integration in Neovim

### Development Tools
- **typescript-tools.nvim** - Enhanced TypeScript language server
- **package-info.nvim** - View and update npm package versions in package.json
- **tmux.nvim** - Seamless navigation between Neovim and tmux panes

---

## Key Mappings

### General
- `;` → Enter command mode (`:`)
- `jk` → Exit insert mode (in insert mode)
- `Space` → Leader key

### Git
- `<leader>gg` (`Space g g`) → Open LazyGit

### AI Assistant
- `<leader>cc` (`Space c c`) → Toggle Claude Code window

### Debugging (DAP)
**Leader mappings:**
- `<leader>db` (`Space d b`) → Toggle breakpoint
- `<leader>dc` (`Space d c`) → Continue/start debugging
- `<leader>do` (`Space d o`) → Step over
- `<leader>di` (`Space d i`) → Step into
- `<leader>du` (`Space d u`) → Step out
- `<leader>dr` (`Space d r`) → Restart frame
- `<leader>dl` (`Space d l`) → Run last debug session
- `<leader>ds` (`Space d s`) → Stop debugger
- `<leader>dR` (`Space d R`) → Toggle DAP REPL
- `<leader>dpr` (`Space d p r`) → Run Python test method under cursor

**Function keys (VS Code style):**
- `F5` → Continue debugging
- `F9` → Toggle breakpoint
- `F10` → Step over
- `F11` → Step into
- `F12` → Step out

### Tmux
- Default tmux keybindings enabled for seamless pane navigation

---

## Configuration Files Structure

```
~/.config/nvim/
├── init.lua                      # Entry point, bootstrap lazy.nvim
├── CLAUDE.md                     # Documentation for Claude Code AI
├── CONFIG_SUMMARY.md             # This file
├── lua/
│   ├── chadrc.lua               # NvChad theme config (onedark)
│   ├── options.lua              # Custom vim options
│   ├── mappings.lua             # Custom keybindings
│   ├── configs/
│   │   ├── lazy.lua             # Lazy.nvim configuration
│   │   ├── lspconfig.lua        # LSP server configurations
│   │   ├── null-ls.lua          # Linting/formatting sources
│   │   ├── conform.lua          # Format orchestration
│   │   ├── dap.lua              # Debug adapter configurations
│   │   ├── treesitter.lua       # Treesitter parsers and settings
│   │   └── rainbow.lua          # Rainbow delimiters config
│   └── plugins/
│       └── init.lua             # Plugin declarations
└── lazy-lock.json               # Plugin version lock (gitignored)
```

---

## Editor Settings

- **Indentation**: Tabs (not spaces), width = 4
- **Leader Key**: Space
- **Theme**: onedark (11 additional themes available)
- **Python Version**: 3.13 (paths configured for site-packages)
- **Virtual Environment**: Uses `$VIRTUAL_ENV` for Python tooling

---

## Python Development Workflow

### Prerequisites
- Set `$VIRTUAL_ENV` environment variable before opening Neovim
- Virtual environment should contain your project dependencies

### Features
- **Type Checking**: Pyright + mypy
- **Linting**: ruff
- **Formatting**: black
- **Debugging**: debugpy with full DAP integration
  - Supports `.vscode/launch.json` files
  - Default FastAPI config for `backend/main.py`
  - Virtual environment auto-detection

### Python Path Configuration
- Interpreter: `$VIRTUAL_ENV/bin/python3`
- Site packages: `$VIRTUAL_ENV/lib/python3.13/site-packages`

---

## JavaScript/TypeScript Development Workflow

### Features
- **Language Server**: typescript-tools with separate diagnostic server
- **Linting**: ESLint with auto-fix on save
- **Formatting**: Prettier
- **Auto-close Tags**: Automatic closing and renaming of JSX/HTML tags
- **Package Management**: npm package version viewer/updater

### Supported File Types
- JavaScript (`.js`)
- TypeScript (`.ts`)
- React (`.jsx`, `.tsx`)

---

## Tailwind CSS

- IntelliSense for all HTML, CSS, JS, JSX, TS, and TSX files
- Auto-completion of Tailwind classes
- Color previews

---

## Debugging Configuration

### Python Debugging
- Uses `debugpy` adapter
- Auto-opens DAP UI when debugging starts
- Supports test method debugging
- FastAPI launch config included
- Reads `.vscode/launch.json` if present

### VS Code Style Keybindings
Function keys F5-F12 work like VS Code for familiar debugging workflow.

---

## How to Use

### First Time Setup
1. Open Neovim - plugins will auto-install
2. Wait for Mason to install language servers and tools
3. Run `:checkhealth` to verify everything is working

### Daily Usage
1. Activate Python virtual environment: `source venv/bin/activate`
2. Open Neovim in project directory: `nvim .`
3. LSP will automatically attach to files
4. Use `<leader>gg` for git operations
5. Use `<leader>cc` for AI assistance
6. Use F5-F12 for debugging

### Managing Plugins
- `:Lazy` - Open plugin manager UI
- `:Lazy sync` - Update all plugins
- `:Lazy clean` - Remove unused plugins

### Managing LSP Tools
- `:Mason` - Open Mason UI
- Navigate with `j/k`, press `i` to install, `X` to uninstall
- All configured tools auto-install on startup

---

## Changes Made Today (2025-11-19)

### 1. Fixed Neovim 0.11+ Compatibility Issues
- **Migrated LSP configuration** from deprecated `lspconfig[server].setup()` to modern `vim.lsp.config` API
- **Replaced null-ls** with maintained fork `none-ls.nvim`
- **Added mason-null-ls bridge** to automatically register Mason tools with none-ls
- **Added mason-tool-installer** for automatic tool installation on startup
- Eliminated all deprecation warnings

### 2. Created Documentation
- Created `CLAUDE.md` with architecture overview and development guidance
- Created `CONFIG_SUMMARY.md` (this file) for quick reference

### 3. Merged dev Branch into main
Successfully merged dev branch with the following additions:

#### JavaScript/TypeScript Support
- Added `typescript-tools.nvim` for TypeScript language server
- Added `eslint_d` for fast linting
- Added `prettier` for code formatting
- Added `nvim-ts-autotag` for auto-closing JSX/HTML tags
- Added JSX filetype detection in init.lua

#### Enhanced Debugging
- Added VS Code-style function key mappings (F5, F9-F12)
- Added additional leader mappings (`<leader>do`, `<leader>di`, etc.)
- Added support for `.vscode/launch.json` files
- Improved virtual environment detection
- Updated FastAPI config for `backend/main.py` structure

#### UI/Visual Enhancements
- Added `rainbow-delimiters.nvim` for colored brackets/parentheses
- Added full Treesitter configuration with text objects
- Enabled `vaf`/`vif` (function) and `vac`/`vic` (class) text objects

#### Additional Tools
- Added `claude-code.nvim` for AI assistance (`<leader>cc`)
- Added `tmux.nvim` for seamless tmux navigation
- Added `package-info.nvim` for npm package management
- Added Tailwind CSS LSP support

#### Updated Configurations
- Updated Python paths from 3.10 to 3.13
- Configured ruff to disable diagnostics (formatting only)
- Added ESLint auto-format on save
- Maintained all Neovim 0.11+ compatibility fixes

### 4. Resolved Merge Conflicts
- Successfully combined compatibility fixes with dev branch features
- Ensured all new features use modern Neovim 0.11+ APIs
- Updated tool installation lists to include JS/TS tools
- Maintained mason-null-ls bridge for all formatters/linters

### 5. Commit History
```
4d642d1 Merge dev branch into main
30e5b15 Fix Neovim 0.11+ compatibility issues
```

---

## Quick Reference Card

| Action | Command/Keybinding |
|--------|-------------------|
| Open command mode | `;` |
| Exit insert mode | `jk` |
| Open LazyGit | `Space g g` |
| Toggle Claude Code | `Space c c` |
| Toggle breakpoint | `Space d b` or `F9` |
| Start/continue debug | `Space d c` or `F5` |
| Step over | `Space d o` or `F10` |
| Step into | `Space d i` or `F11` |
| Step out | `Space d u` or `F12` |
| Open plugin manager | `:Lazy` |
| Open Mason | `:Mason` |
| Check health | `:checkhealth` |

---

## Troubleshooting

### LSP Not Working
- Check virtual environment is activated: `echo $VIRTUAL_ENV`
- Run `:LspInfo` to see attached servers
- Run `:checkhealth lsp` for diagnostics

### Tools Not Found
- Open `:Mason` and verify tools are installed
- Check `:checkhealth mason` for issues
- Restart Neovim to trigger auto-installation

### Debugging Not Working
- Verify debugpy is installed: `:Mason`
- Check Python path is correct: `:lua print(vim.fn.expand("$VIRTUAL_ENV"))`
- Run `:checkhealth dap` for diagnostics

---

*Last Updated: 2025-11-19*
*Configuration Version: NvChad v2.5 + Custom Enhancements*
