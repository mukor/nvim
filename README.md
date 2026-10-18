# NvChad Neovim Configuration

Personal Neovim configuration built on **NvChad v2.5** for Python, JavaScript/TypeScript, and web development, with Claude Code integration and Zettelkasten-style notes. Works on macOS and Linux.

## Features

### Language Support
- **Python**: pyright (types/IntelliSense) + ruff (lint, format, organize imports), debugpy; per-project venv detection (uv `.venv` aware)
- **JavaScript/TypeScript**: typescript-tools.nvim, ESLint (format on save), Prettier
- **Web**: HTML, CSS, Tailwind CSS IntelliSense; auto-close and rename HTML/JSX tags
- **Lua**: lua_ls + stylua

### Development Tools
- **LSP** via the native `vim.lsp.config` API, auto-completion via NvChad's nvim-cmp
- **Formatting**: conform.nvim (ruff, prettier, stylua), run on demand; format-on-save is off by default (ESLint still formats JS/TS on save)
- **Debugging**: DAP with VS Code-style keys (F5, F9–F12), auto-opening debug UI, `.vscode/launch.json` support
- **Git**: LazyGit (`Space g g`) and gitsigns hunk actions
- **AI**: Claude Code via claudecode.nvim, as a horizontal, vertical, or floating pane (`Space c c`)
- **Notes**: Telekasten with calendar (`Space z`), plus brain-rag tag completion and note snippets
- **Remote editing**: edit files on remote servers via SSHFS (`Space r c`)

### Editing & UI
- **mini.move**: move lines or selections with `Alt+h/j/k/l`
- **mini.surround**: add/delete/replace surrounding characters (`sa` / `sd` / `sr`)
- **Treesitter**: highlighting, folds, indent, and function/class text objects (`af`, `if`, `ac`, `ic`)
- **Rainbow delimiters**, **tmux** pane navigation (`Ctrl+h/j/k/l`)
- **Theme**: custom Rose Pine Moon (`rosepine-moon`); switch with NvChad's theme picker

## Prerequisites

- **Neovim** 0.12+
- **git**, **ripgrep**, a C compiler (for treesitter parsers)
- **Node.js**: JS/TS language servers, Prettier, Pyright
- **Lazygit**: git UI
- **Python 3**: debugging and Python LSPs; a project `.venv` or an activated virtualenv is picked up automatically
- Optional:
  - **sshfs** for remote editing. Linux: `sudo apt install sshfs`. macOS: `brew install --cask macfuse` and `brew install gromgit/fuse/sshfs-mac`
  - **viu** (or ueberzugpp on Linux) for image previews in Telekasten
  - **brain-rag** CLI for note tag completion: run `./install.sh` in the [brain-rag](https://github.com/mukor/brain-rag) repo, and clone brain-rag.nvim to `~/dev/brain-rag.nvim`

## Installation

1. Clone this repository to your Neovim config directory:
   ```bash
   git clone https://github.com/mukor/nvim.git ~/.config/nvim
   ```
2. Open Neovim. lazy.nvim installs the plugins, then Mason installs the language servers and tools:
   ```bash
   nvim
   ```
3. Verify the install:
   ```bash
   ~/.config/nvim/test/run.sh
   ```
   or inside Neovim: `:checkhealth`

## Quick Start

### Python
```bash
cd my-project
uv venv          # or activate any virtualenv
nvim .
```
The interpreter is resolved as `$VIRTUAL_ENV` → `<project>/.venv` → system `python3`, for both pyright and the debugger.

### Key Mappings

Leader is `Space`.

| Action | Keybinding |
|--------|-----------|
| Command mode | `;` |
| Exit insert mode | `jk` |
| Exit terminal, back to previous window | `Ctrl+o` (in a terminal) |
| Move line / selection | `Alt+h/j/k/l` |
| Surround / delete / replace | `sa{char}` / `sd{char}` / `sr{old}{new}` |
| LazyGit | `Space g g` |
| Next / prev git hunk | `]h` / `[h` |
| Stage / reset / preview hunk | `Space h s` / `Space h r` / `Space h p` |
| Claude pane picker | `Space c c` |
| Send selection to Claude | `Space c s` (visual) |
| Accept / deny Claude diff | `Space c a` / `Space c d` |
| Toggle breakpoint | `Space d b` or `F9` |
| Start / continue debugging | `Space d c` or `F5` |
| Step over / into / out | `F10` / `F11` / `F12` |
| Run Python test method | `Space d p r` |
| Telekasten panel | `Space z` |
| Find / search notes | `Space z f` / `Space z g` |
| New note / daily note | `Space z n` / `Space z d` |
| Follow link / backlinks | `Space z z` / `Space z b` |
| Meeting note from line | `Space z m` |
| Markdown preview | `Space m p` |
| Insert symbol/emoji | `Space s e` |
| Connect / disconnect remote | `Space r c` / `Space r d` |
| Find files / grep (remote) | `Space r f` / `Space r g` |

See [CONFIG_SUMMARY.md](CONFIG_SUMMARY.md) for the complete list.

## Core Plugins

### LSP & Tools
- **mason.nvim** + **mason-tool-installer.nvim**: auto-install lua-language-server, stylua, pyright, ruff, debugpy, prettier, typescript-language-server, and the html, css, eslint, and tailwindcss servers
- **nvim-lspconfig**: server definitions for pyright, ruff, html, cssls, eslint, tailwindcss, lua_ls
- **typescript-tools.nvim**: TS/JS language server
- **conform.nvim**: formatting (ruff, prettier, stylua)

### Debugging
- **nvim-dap**, **nvim-dap-ui**, **nvim-dap-python** (debugpy), **nvim-nio**

### Development
- **lazygit.nvim**, **gitsigns.nvim**: git
- **claudecode.nvim** + **snacks.nvim**: Claude Code integration
- **tmux.nvim**: tmux navigation
- **package-info.nvim**: npm versions in `package.json`

### Notes
- **telekasten.nvim** + **calendar-vim**: Zettelkasten notes in `~/notes`
- **brain-rag.nvim** (local): tag completion, note-type snippets, tag sync
- **telescope-media-files.nvim**: image previews
- **markdown-preview.nvim**: live preview in the browser
- **telescope-symbols.nvim**: emoji and symbol picker

### Editing & Syntax
- **nvim-treesitter** + **nvim-treesitter-textobjects** (`main` branch)
- **mini.move**, **mini.surround**, **nvim-ts-autotag**, **rainbow-delimiters.nvim**

### Remote
- **remote-sshfs.nvim**: mount and edit remote hosts from `~/.ssh/config`

## Note-Taking with Telekasten

Zettelkasten-style notes with wiki-links, tags, and calendar integration.

### Setup
```bash
mkdir -p ~/notes
```

### Usage
- `Space z` opens the Telekasten panel with all commands
- Link notes with `[[note-name]]`; tag with `#tag`
- `:Telekasten show_calendar` for a sidebar calendar, `:CalendarT` for full screen. Days with notes show `+`; `Enter` opens or creates that day's note
- With brain-rag installed, typing tags in markdown offers completions from your vault

### Image Preview

Telekasten uses viu for image previews:

| Platform | Install | Quality | Notes |
|----------|---------|---------|-------|
| **macOS (iTerm2)** | `brew install viu` | Smooth images | Native iTerm2 image protocol |
| **Ubuntu/Linux** | `sudo apt install ueberzugpp` | Pixel-perfect | Renders as an overlay; needs X11 or Wayland |
| **WSL2 (Windows Terminal)** | `cargo install viu --features=sixel` | Block characters | Neovim's terminal doesn't pass Sixel through |

Use `:Telekasten insert_img_link` (`Space z I`) to browse and insert images, or `:Telescope media_files` to browse directly.

## Configuration Files

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── chadrc.lua          # NvChad config (theme: rosepine-moon)
│   ├── options.lua         # Editor options (tabs, width 4)
│   ├── mappings.lua        # Keybindings
│   ├── themes/             # Custom base46 theme
│   ├── utils/venv.lua      # Python interpreter resolver
│   ├── configs/            # Plugin configurations (lsp, conform, dap, treesitter, ...)
│   └── plugins/init.lua    # Plugin declarations
└── test/                    # Headless smoke test
```

## Documentation

- **[CONFIG_SUMMARY.md](CONFIG_SUMMARY.md)**: complete reference for plugins, keybindings, and workflows
- **[CLAUDE.md](CLAUDE.md)**: architecture guide for AI assistants
- **[NOTES_INGEST.md](NOTES_INGEST.md)**: original design doc for the notes RAG system (since built as brain-rag)

## Troubleshooting

### Check the whole config
```bash
~/.config/nvim/test/run.sh
```
Reports missing plugins, failed builds, plugin load errors, treesitter problems, and missing tools.

### LSP not working
```vim
:checkhealth vim.lsp
:lua print(require("utils.venv").python())
```

### Tools not found
```vim
:Mason
:checkhealth mason
```

### `:Lazy sync` says a plugin has local changes
Something modified files inside the plugin's checkout. In `:Lazy`, press `x` on the plugin to remove it, then `I` to reinstall.

### Theme looks wrong after editing the palette
```bash
nvim --headless -c 'lua require("base46").compile()' -c 'qa'
```

## License

See [LICENSE](LICENSE).

---

*Built with NvChad v2.5*
