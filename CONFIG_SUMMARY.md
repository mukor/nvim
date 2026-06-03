# NvChad Neovim Configuration Summary

## Overview

This is a Neovim configuration built on **NvChad v2.5**, customized for:
- Python development (LSP, debugging, linting, formatting) with **uv**-style per-project venvs
- JavaScript/TypeScript/React + Tailwind CSS
- Git integration (LazyGit + gitsigns)
- Debugging via DAP
- AI assistance via **Claude Code** (claudecode.nvim)
- Zettelkasten note-taking (Telekasten) and remote editing (SSHFS)

**Neovim Version**: 0.11.5
**Plugin Manager**: lazy.nvim
**Leader Key**: `Space`
**Theme**: `rosepine-moon` (custom, canonical Rose Pine Moon palette)
**Indentation**: real tab characters, width 4

---

## Plugins

### Core Framework
- **NvChad** (v2.5) — base UI, themes, defaults
- **lazy.nvim** — plugin manager with lazy loading

### LSP & Tooling Management
- **mason.nvim** — installs LSP servers / formatters / linters
- **mason-tool-installer.nvim** — auto-installs the configured tool list on startup
- **nvim-lspconfig** — LSP server configs (uses the modern `vim.lsp.config` / `vim.lsp.enable` API)

Mason auto-installs: `lua-language-server`, `stylua`, `pyright`, `ruff`, `debugpy`, `prettier`, `typescript-language-server`.

### LSP Servers Configured
- **pyright** — Python type checking + IntelliSense (per-workspace venv resolution; lint-style diagnostics deferred to ruff; UTF-8 position encoding to agree with ruff)
- **ruff** — fast Python linter via LSP diagnostics (hover disabled — deferred to pyright)
- **html** / **cssls** — web language servers
- **eslint** — JS/TS linting with format-on-save
- **tailwindcss** — Tailwind class IntelliSense (html/css/js/jsx/ts/tsx)
- **typescript-tools.nvim** — TS/JS language server (used instead of the lspconfig tsserver)

> Note: `none-ls`/`null-ls`, `mypy`, and `black` were removed. Python is now **pyright + ruff** only, with formatting via conform.

### Linting & Formatting
- **conform.nvim** — formatter orchestration:
  - Lua → `stylua`
  - Python → `ruff_organize_imports` + `ruff_format`
  - JS/TS/JSON/JSONC/HTML/CSS/Markdown/YAML → `prettier`
  - Format-on-save is **off by default** (commented block in `configs/conform.lua`)
- **eslint** LSP formats JS/TS on save (separate from conform)

### Debugging (DAP)
- **nvim-dap** — Debug Adapter Protocol client
- **nvim-dap-ui** — debug UI (auto open/close with sessions)
- **nvim-dap-python** — Python debugging via debugpy
- **nvim-nio** — async I/O (required by dap-ui)
- `.vscode/launch.json` is auto-loaded on demand; a FastAPI fallback config (`backend/main.py`) is included

### Editing Enhancements
- **mini.move** — move a Visual selection or the current line with `Alt+hjkl`
- **mini.surround** — add/delete/replace surrounding chars (`sa`/`sd`/`sr`)
- **nvim-treesitter-textobjects** — function/class text objects (`af`/`if`/`ac`/`ic`)
- **nvim-ts-autotag** — auto-close/rename HTML/JSX tags
- **rainbow-delimiters.nvim** — color-coded brackets

### Syntax & Parsing
- **nvim-treesitter** (pinned to `master` branch) — parsers: lua, vim, vimdoc, html, css, javascript, typescript, tsx, json, python

### Git Integration
- **lazygit.nvim** — terminal Git UI
- **gitsigns.nvim** — hunk navigation, stage/reset/preview/blame/diff

### AI Assistance
- **claudecode.nvim** — implements the same WebSocket/MCP protocol as the official VS Code / JetBrains extensions (selection sending, diff accept/reject, shared buffer & diagnostic context). Uses the **snacks.nvim** terminal provider so the pane can open horizontal/vertical/floating.

### Notes / Remote / Misc
- **telekasten.nvim** — Zettelkasten notes with calendar (notes in `~/notes`)
- **telescope-media-files.nvim** — image preview for Telekasten
- **markdown-preview.nvim** — live Markdown preview in browser
- **telescope-symbols.nvim** — emoji/symbol picker
- **remote-sshfs.nvim** — edit remote files over SSHFS
- **tmux.nvim** — seamless Neovim ⇆ tmux pane navigation (`Ctrl+hjkl`)
- **package-info.nvim** — view/update npm versions in `package.json`
- **brain-rag.nvim** (local) — semantic notes integration

---

## Key Mappings

### General
- `;` → Enter command mode (`:`)
- `jk` → Exit insert mode (insert mode)
- `<C-o>` → (terminal mode) exit terminal **and** jump back to the previously focused window in one press
- `Space` → Leader key

### Editing — Move (mini.move)
- `Alt+h` / `Alt+l` → move selection/line left / right (by a character)
- `Alt+j` / `Alt+k` → move selection/line down / up (auto-reindents)
- Works in **Visual** mode (the selection) and **Normal** mode (the current line)

### Editing — Surround (mini.surround)
- `sa{char}` → **add** surrounding (Visual: around selection; Normal: `sa{motion}{char}`, e.g. `saiw"`)
- `sd{char}` → **delete** surrounding (e.g. `sd"`)
- `sr{old}{new}` → **replace** surrounding (e.g. `sr"'`)
- `sf` / `sF` → find surrounding right / left
- `sh` → highlight surrounding
- `sn` → update search range (`n_lines`)
- Tags: `sat` then type a tag name → `<tag>…</tag>`

### Editing — Text Objects (treesitter)
- `af` / `if` → a function / inner function (e.g. `vaf`, `dif`)
- `ac` / `ic` → a class / inner class

### Git
- `<leader>gg` → Open LazyGit
- `]h` / `[h` → next / previous git hunk
- `<leader>hs` → stage hunk
- `<leader>hr` → reset hunk
- `<leader>hp` → preview hunk
- `<leader>hb` → blame line (full)
- `<leader>hd` → diff this

### AI Assistant (Claude Code)
- `<leader>cc` → **Claude pane picker** — floating popup; `h/j/k/l` to select Horizontal / Vertical / Floating, each row shows what it will do (open / close / switch). The existing Claude window is moved in place so the session survives layout changes.
- `<leader>cf` → focus Claude pane
- `<leader>cr` → resume Claude (`--resume`)
- `<leader>cC` → continue Claude (`--continue`)
- `<leader>cb` → add current buffer to context
- `<leader>cs` → (Visual) send selection to Claude
- `<leader>ca` → accept diff
- `<leader>cd` → deny diff

### Debugging (DAP)
**Leader mappings:**
- `<leader>db` → Toggle breakpoint
- `<leader>dc` → Continue / start debugging
- `<leader>do` → Step over
- `<leader>di` → Step into
- `<leader>du` → Step out
- `<leader>dr` → Restart frame
- `<leader>dl` → Run last debug session
- `<leader>ds` → Stop debugger
- `<leader>dR` → Toggle DAP REPL
- `<leader>dpr` → Run Python test method under cursor

**Function keys (VS Code style):**
- `F5` → Continue · `F9` → Toggle breakpoint · `F10` → Step over · `F11` → Step into · `F12` → Step out

### Notes (Telekasten)
- `<leader>z` → panel · `<leader>zf` → find notes · `<leader>zg` → search notes
- `<leader>zn` → new note · `<leader>zd` → daily note · `<leader>zt` → toggle todo
- `<leader>zb` → backlinks · `<leader>zz` → follow link · `<leader>zc` → calendar · `<leader>zI` → insert image

### Remote (SSHFS)
- `<leader>rc` → connect · `<leader>rd` → disconnect · `<leader>re` → edit ssh config
- `<leader>rf` → find files on remote · `<leader>rg` → live grep on remote

### Misc
- `<leader>mp` → toggle Markdown preview
- `<leader>se` → insert symbol / emoji
- Tmux navigation: `Ctrl+h/j/k/l` move between Neovim splits and tmux panes

---

## Configuration Files Structure

```
~/.config/nvim/
├── init.lua                      # Entry point, bootstrap lazy.nvim, load theme cache
├── CLAUDE.md                     # Guidance for Claude Code AI
├── CONFIG_SUMMARY.md             # This file
├── lua/
│   ├── chadrc.lua                # NvChad config (theme = rosepine-moon, hl_override)
│   ├── options.lua               # Custom vim options (tabs, width 4)
│   ├── mappings.lua              # Custom keybindings
│   ├── themes/
│   │   └── rosepine-moon.lua     # Custom Rose Pine Moon palette
│   ├── utils/
│   │   └── venv.lua              # Python interpreter resolver (uv .venv aware)
│   ├── configs/
│   │   ├── lazy.lua              # lazy.nvim config
│   │   ├── lspconfig.lua         # LSP servers (vim.lsp.config API)
│   │   ├── conform.lua           # Formatter orchestration
│   │   ├── dap.lua               # Debug adapter configs
│   │   ├── treesitter.lua        # Parsers + text objects
│   │   └── rainbow.lua           # Rainbow delimiters
│   └── plugins/
│       └── init.lua              # Plugin declarations
└── lazy-lock.json                # Plugin version lock (gitignored)
```

---

## Editor Settings

- **Indentation**: real tab characters (`expandtab = false`), `tabstop`/`shiftwidth`/`softtabstop` = 4
- **Leader Key**: Space
- **Theme**: `rosepine-moon` (with `hl_override` for a brighter Visual selection matching Ghostty, plus italic comments/emphasis)

---

## Python Development Workflow (uv-style)

Python tooling resolves the interpreter the same way everywhere (pyright, DAP) via `lua/utils/venv.lua`:

1. `$VIRTUAL_ENV/bin/python` (if an env is active)
2. `<project root>/.venv/bin/python` (the **uv** convention)
3. system `python3`

No global virtualenvwrapper / hardcoded version paths. Just `uv venv` in a project (creating `.venv/`) and open Neovim there.

### Features
- **Type checking**: pyright (lint-style diagnostics deferred to ruff)
- **Linting**: ruff (LSP diagnostics)
- **Formatting**: ruff (`ruff_organize_imports` + `ruff_format`) via conform
- **Debugging**: debugpy + DAP UI; reads `.vscode/launch.json`; FastAPI fallback config

---

## JavaScript/TypeScript Development Workflow

- **Language server**: typescript-tools.nvim (separate diagnostic server, diagnostics on `InsertLeave`)
- **Linting**: ESLint (format-on-save via LSP)
- **Formatting**: Prettier (via conform)
- **Tailwind**: IntelliSense across html/css/js/jsx/ts/tsx
- **Tags**: auto-close/rename JSX & HTML
- **npm**: package-info shows/updates versions in `package.json`
- File types: `.js`, `.ts`, `.jsx` (mapped to `javascriptreact`), `.tsx`

---

## How to Use

### First-Time Setup
1. Open Neovim — lazy.nvim installs plugins
2. Wait for Mason to install language servers / tools
3. Run `:checkhealth` to verify

### Daily Usage
1. In a Python project, ensure a `.venv/` exists (`uv venv`) or activate an env
2. `nvim .` in the project — LSP attaches automatically
3. `<leader>gg` for Git, `<leader>cc` for Claude, `F5`–`F12` for debugging

### Managing Plugins
- `:Lazy` — plugin manager UI · `:Lazy sync` — update · `:Lazy clean` — remove unused

### Managing LSP Tools
- `:Mason` — UI (`i` install, `X` uninstall); configured tools auto-install on startup

---

## Quick Reference Card

| Action | Command / Keybinding |
|--------|----------------------|
| Command mode | `;` |
| Exit insert mode | `jk` |
| Exit terminal → prev window | `Ctrl+o` (in terminal) |
| Move selection/line | `Alt+h/j/k/l` |
| Surround selection | `sa{char}` (e.g. `sa"`) |
| Delete / replace surround | `sd"` / `sr"'` |
| Open LazyGit | `Space g g` |
| Next / prev git hunk | `]h` / `[h` |
| Stage / reset hunk | `Space h s` / `Space h r` |
| Claude pane picker | `Space c c` |
| Focus Claude | `Space c f` |
| Toggle breakpoint | `Space d b` or `F9` |
| Start / continue debug | `Space d c` or `F5` |
| Daily note | `Space z d` |
| Connect remote (SSHFS) | `Space r c` |
| Markdown preview | `Space m p` |
| Open plugin manager | `:Lazy` |
| Open Mason | `:Mason` |
| Check health | `:checkhealth` |

---

## Troubleshooting

### LSP Not Working
- Confirm the interpreter resolves: `:lua print(require("utils.venv").python())`
- Run `:LspInfo` to see attached servers; `:checkhealth lsp` for diagnostics

### Tools Not Found
- Open `:Mason` and verify installs; `:checkhealth mason`; restart to trigger auto-install

### Debugging Not Working
- Verify debugpy in `:Mason`
- Check the resolved Python path (see LSP tip above); `:checkhealth dap`

### Theme Looks Wrong After Palette Edits
- Recompile the base46 cache: `nvim --headless -c 'lua require("base46").compile()' -c 'qa'`

---

*Last Updated: 2026-06-03*
*Configuration Version: NvChad v2.5 + Custom Enhancements*
