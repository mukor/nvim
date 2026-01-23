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
- **Note-taking**: Telekasten with calendar integration (`Space z`)

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
| Telekasten panel | `Space z` |
| Find notes | `Space z f` |
| Search notes | `Space z g` |
| New note | `Space z n` |
| Daily note | `Space z d` |

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
- **telekasten.nvim** - Zettelkasten note-taking (notes stored in `~/notes`)
- **calendar-vim** - Calendar integration for Telekasten
- **telescope-media-files.nvim** - Image preview in Telescope

### Syntax & UI
- **nvim-treesitter** - Advanced syntax highlighting
- **rainbow-delimiters.nvim** - Colored brackets
- **nvim-ts-autotag** - Auto-close HTML/JSX tags

## Note-Taking with Telekasten

Zettelkasten-style note-taking with wiki-links, tags, and calendar integration.

### Setup
```bash
mkdir -p ~/notes
```

### Usage
- `Space z` opens the Telekasten panel with all commands
- Create wiki-links with `[[note-name]]` syntax
- Add tags with `#tag`
- Use `:Telekasten show_calendar` for visual date navigation

### Calendar
- Days with notes show a `+` symbol
- Press `Enter` on a date to open/create that day's note
- `:CalendarT` for full-screen calendar view

### Image Preview

Telekasten uses viu for image previews. Install the appropriate backend for your platform:

| Platform | Install Command | Preview Quality | Notes |
|----------|-----------------|-----------------|-------|
| **WSL2 (Windows Terminal)** | `cargo install viu --features=sixel` | Block characters | Neovim's terminal doesn't pass through Sixel |
| **macOS (iTerm2)** | `brew install viu` | Smooth images | iTerm2 protocol supported natively |
| **Ubuntu/Linux** | `sudo apt install ueberzugpp` | Pixel-perfect | ueberzugpp renders outside Neovim |

#### Platform Limitations

**WSL2 + Windows Terminal:**
- Windows Terminal supports Sixel (v1.22+), and `viu` works perfectly in the terminal directly
- However, Neovim's built-in terminal emulator doesn't pass Sixel escape sequences to the outer terminal
- Result: Block character (▄) previews inside Neovim, which are functional but not smooth
- Workaround: Use WezTerm with SSH, or accept block previews

**macOS (iTerm2):**
- viu auto-detects iTerm2 and uses native image protocol
- Smooth image previews should work out of the box

**Ubuntu/Linux:**
- ueberzugpp renders images as overlays outside Neovim's terminal
- Provides pixel-perfect image previews
- Requires X11 or Wayland

Usage:
- `:Telekasten insert_img_link` - Browse and insert images with preview
- `:Telescope media_files` - Browse media files directly

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
