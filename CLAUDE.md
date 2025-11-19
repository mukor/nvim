# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration built on top of NvChad v2.5, customized for Python development with LSP, debugging, formatting, and linting capabilities. The configuration uses lazy.nvim for plugin management.

## Prerequisites

- Lazygit (for git integration)
- Node.js
- Go
- Python with virtual environment support

## Architecture

### Configuration Entry Point

- `init.lua`: Bootstrap file that sets up lazy.nvim, loads NvChad base, configures theme, and applies custom options
  - Sets leader key to space
  - Configures tabs (4 spaces, actual tab characters instead of spaces)
  - Loads plugins from `lua/plugins/init.lua`

### Core Configuration Files

- `lua/chadrc.lua`: NvChad theme configuration (currently using "onedark" theme)
- `lua/options.lua`: Custom vim options (extends NvChad defaults)
- `lua/mappings.lua`: Custom keybindings
  - `;` mapped to `:` for command mode
  - `jk` mapped to `<ESC>` in insert mode
  - `<leader>gg` opens LazyGit
  - DAP debugging keybindings: `<leader>db` (toggle breakpoint), `<leader>dc` (continue), `<leader>dpr` (run Python test method)

### Plugin Configuration

Located in `lua/configs/`:

1. **LSP Configuration** (`lspconfig.lua`):
   - Configured servers: html, cssls, pyright, ruff
   - Pyright configured to use `$VIRTUAL_ENV/bin/python` for Python path
   - Python analysis uses `$VIRTUAL_ENV/lib/python3.10/site-packages` as extraPaths
   - Black configured as formatter with tab indentation

2. **Null-ls Configuration** (`null-ls.lua`):
   - mypy diagnostics (uses virtual environment Python)
   - ruff diagnostics
   - black formatting

3. **Conform Configuration** (`conform.lua`):
   - stylua for Lua formatting
   - format_on_save is commented out by default

4. **DAP Configuration** (`dap.lua`):
   - Python debugger setup with debugpy
   - FastAPI launch configuration targeting `main.py` with host 172.27.139.9:8000
   - Uses system Python3 with debugpy module

### Plugin Stack

Key plugins from `lua/plugins/init.lua`:

- **Mason**: Auto-installs pyright, mypy, ruff, black, debugpy
- **nvim-lspconfig**: LSP integration
- **null-ls**: Additional diagnostics and formatting
- **conform.nvim**: Formatting orchestration
- **nvim-dap + nvim-dap-ui**: Debugging interface
- **nvim-dap-python**: Python-specific DAP configuration (debugpy at `~/.local/share/nvim/mason/packages/debugpy/venv/bin/python`)
- **lazygit.nvim**: Git interface integration

## Python Development Workflow

### Virtual Environment Handling

The configuration expects a `$VIRTUAL_ENV` environment variable to be set:
- Pyright uses `$VIRTUAL_ENV/bin/python` as the Python interpreter
- Pyright analysis includes `$VIRTUAL_ENV/lib/python3.10/site-packages`
- mypy uses the virtual environment Python executable

Note: The site-packages path is hardcoded to Python 3.10. Adjust in `lua/configs/lspconfig.lua` and `lua/configs/null-ls.lua` if using a different Python version.

### LSP Servers

- **pyright**: Type checking and IntelliSense
- **ruff**: Fast Python linter
- **html/cssls**: Web development support

### Formatting and Linting

- Primary formatter: black (via null-ls)
- Linters: mypy, ruff (via null-ls)
- Format-on-save is disabled by default

### Debugging

Python debugging uses DAP with debugpy:
- `<leader>db`: Toggle breakpoint
- `<leader>dc`: Continue/start debugging
- `<leader>dpr`: Run test method under cursor
- DAP UI automatically opens/closes with debug sessions
- Default launch config targets FastAPI apps at `main.py`

## Modifying Configuration

### Adding New LSP Servers

Add to the `servers` table in `lua/configs/lspconfig.lua`:
```lua
local servers = { "html", "cssls", "pyright", "ruff", "new_server" }
```

Ensure Mason installs it in `lua/plugins/init.lua`.

### Adding Custom Keybindings

Add to `lua/mappings.lua` using the `map` function or extend the `keymaps` table in `M.load_mappings`.

### Changing Python Version Paths

Update hardcoded `python3.10` paths in:
- `lua/configs/lspconfig.lua` (line 61)
- Comment indicates to adjust as needed

### Theme Changes

Modify `M.base46.theme` in `lua/chadrc.lua`.

## File Structure

```
.
├── init.lua                 # Bootstrap and entry point
├── lua/
│   ├── chadrc.lua          # NvChad configuration
│   ├── mappings.lua        # Custom keybindings
│   ├── options.lua         # Custom vim options
│   ├── configs/            # Plugin configurations
│   │   ├── lazy.lua        # Lazy.nvim config
│   │   ├── lspconfig.lua   # LSP servers setup
│   │   ├── null-ls.lua     # Diagnostics/formatting
│   │   ├── conform.lua     # Format orchestration
│   │   └── dap.lua         # Debug adapter protocol
│   └── plugins/
│       └── init.lua        # Plugin declarations
└── lazy-lock.json          # Plugin version lock (gitignored)
```
