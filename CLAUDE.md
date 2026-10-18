# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Neovim configuration built on NvChad v2.5 and lazy.nvim, targeting **Neovim 0.12+**. Focus areas: Python (pyright + ruff, debugpy), JS/TS/React + Tailwind, Claude Code integration, Telekasten notes (with the local brain-rag plugin), and remote editing over SSHFS. Used on both macOS and Linux, so keep paths portable (no hardcoded `/home/...` or `/Users/...`).

User-facing docs: `README.md` (overview/install) and `CONFIG_SUMMARY.md` (full plugin + keymap reference). Keep all three in sync when changing plugins or keymaps.

## Testing

Run the headless smoke test after any config change or `:Lazy sync`:

```bash
test/run.sh        # optional arg: timeout in seconds (default 120)
```

`test/smoke.lua` is loaded with `--cmd` (before `init.lua`) so it can hook `vim.notify`. It then:
- checks every plugin is installed with no failed lazy tasks (e.g. builds)
- force-loads every lazy plugin
- opens sample markdown/python/lua/json/html/css files and parses treesitter including injections (fenced code blocks)
- warns about Mason `ensure_installed` packages that aren't installed, and missing external tools
- fails on any error in `:messages` or `vim.notify`

Exits non-zero on failure. It does not yet verify that LSP servers attach. It sets `vim.g.smoke_test = true` so config can skip side effects a short-lived nvim would break (currently: mason-tool-installer's startup install). Note that `VeryLazy` fires on `UIEnter`, which never happens headless.

Quick syntax check of a single file: `nvim --headless -c 'luafile <file>' -c 'qa!'`.

## Architecture

### Entry point

`init.lua`: sets `vim.g.base46_cache` and leader (space), bootstraps lazy.nvim, imports `nvchad.plugins` (NvChad v2.5) plus `lua/plugins/`, loads the base46 theme cache, then `options`, `nvchad.autocmds`, and (scheduled) `mappings`. Also maps `.jsx` → `javascriptreact`.

### Core files

- `lua/chadrc.lua`: NvChad config. Theme `rosepine-moon` plus `hl_override` (Visual matches Ghostty's selection color, italic comments/emphasis).
- `lua/themes/rosepine-moon.lua`: custom base46 theme (canonical Rose Pine Moon palette). After palette edits, recompile: `nvim --headless -c 'lua require("base46").compile()' -c 'qa'`.
- `lua/options.lua`: extends `nvchad.options`. Real tab characters (`expandtab = false`), width 4.
- `lua/mappings.lua`: extends `nvchad.mappings`. Global maps plus `M.load_mappings(mode)`, which registers the `dap` / `dap_python` keymap tables when those plugins load.
- `lua/utils/venv.lua`: `python(root)` resolves the interpreter as `$VIRTUAL_ENV/bin/python` → `<root>/.venv/bin/python` (uv) → system `python3`. Used by pyright and DAP; don't hardcode Python paths elsewhere.
- `lua/plugins/init.lua`: all plugin specs. Also contains the Claude pane layout switcher and picker (`claude_open_in`, `claude_picker`) used by `<leader>cc`.

### Plugin configs (`lua/configs/`)

- `lazy.lua`: lazy.nvim options. `defaults.lazy = true`, so every plugin needs a trigger (`ft`, `cmd`, `keys`, `event`) or `lazy = false`.
- `lspconfig.lua`: uses the native `vim.lsp.config` / `vim.lsp.enable` API (not `require("lspconfig").x.setup`). Enables html, cssls, pyright, ruff, eslint, tailwindcss; NvChad's defaults add lua_ls.
  - pyright: interpreter from `utils.venv` at init time, UTF-8 position encoding (to match ruff), unused-* diagnostics disabled (ruff reports them).
  - ruff: hover disabled (pyright handles hover).
  - eslint: formats on save via `BufWritePre`.
  - tailwindcss: html/css/js/jsx/ts/tsx.
- `conform.lua`: formatters by filetype. stylua (Lua), `ruff_organize_imports` + `ruff_format` (Python), prettier (JS/TS/JSON/HTML/CSS/Markdown/YAML). Format-on-save is off (commented out).
- `dap.lua`: Python adapter (`python3 -m debugpy.adapter`), FastAPI fallback config for `${workspaceFolder}/backend/main.py` on 127.0.0.1:8000. `.vscode/launch.json` is auto-loaded by nvim-dap.
- `treesitter.lua`: nvim-treesitter **main** branch. There is no `setup{}` or `nvim-treesitter.configs`; it calls `install(langs)` and a `FileType` autocmd runs `vim.treesitter.start()` and sets fold/indent exprs. Add parsers to `langs`.
- `treesitter-textobjects.lua`: textobjects **main** branch. Configured with its own `setup()`; keymaps (`af`/`if`/`ac`/`ic`) call `select_textobject` explicitly.
- `rainbow.lua`: rainbow-delimiters strategy/query settings.

null-ls/none-ls, mypy, and black were removed; Python is pyright + ruff only, with formatting via conform.

### Plugins of note (`lua/plugins/init.lua`)

- **mason-tool-installer**: loads on `VeryLazy` and calls `run_on_start()` from its config (its own `VimEnter` hook has already fired by then). Auto-installs lua-language-server, stylua, pyright, ruff, debugpy, prettier, html-lsp, css-lsp, eslint-lsp, tailwindcss-language-server, typescript-language-server (Mason package names, not lspconfig server names).
- **typescript-tools.nvim**: TS/JS language server (instead of lspconfig's ts_ls).
- **nvim-dap / dap-ui / dap-python**: dap-ui opens/closes with sessions; dap-python uses Mason's debugpy venv.
- **claudecode.nvim** (coder): WebSocket/MCP protocol like the VS Code extension; uses the snacks.nvim terminal provider so the pane can be horizontal, vertical, or floating.
- **gitsigns**: shipped by NvChad; this spec only adds keymaps.
- **mini.move / mini.surround**: Alt+hjkl moves; `sa`/`sd`/`sr` surround with a custom `B` (markdown bold `**…**`).
- **telekasten** (+ calendar-vim, telescope-media-files with viu), **markdown-preview** (built with `mkdp#util#install()`, not `npm install`, which dirties the plugin's git tree and blocks lazy updates), **telescope-symbols**, **remote-sshfs**, **tmux.nvim**, **package-info**, **nvim-ts-autotag**, **rainbow-delimiters**.
- **brain-rag.nvim**: local plugin at `~/dev/brain-rag.nvim` (`dir =` spec, markdown only). Tag completion via nvim-cmp, LuaSnip note-type snippets, tag sync, `<leader>zm` (meeting note from line). Calls the `brain-rag` CLI from PATH, falling back to `~/.local/bin/brain-rag`. The CLI is installed by `~/dev/brain-rag/install.sh` (`uv tool install`).

## Keybindings

Defined in `lua/mappings.lua` (global, DAP) and in plugin specs' `keys` (everything else). Full list in `CONFIG_SUMMARY.md`. Groups:
- General: `;` → `:`, `jk` → Esc, `<C-o>` in terminal mode exits and returns to the previous window
- `<leader>gg` LazyGit · `]h`/`[h` and `<leader>h*` gitsigns hunks
- `<leader>c*` Claude Code (`cc` pane picker, `cf` focus, `cr` resume, `cC` continue, `cb` add buffer, `cs` send selection, `ca`/`cd` accept/deny diff)
- `<leader>d*` and F5/F9–F12 DAP; `<leader>dpr` run Python test method
- `<leader>z*` Telekasten; `<leader>zm` brain-rag meeting note
- `<leader>r*` remote SSHFS · `<leader>mp` markdown preview · `<leader>se` symbols
- Alt+hjkl mini.move · `sa`/`sd`/`sr`/`sf`/`sF`/`sh`/`sn` mini.surround · `af`/`if`/`ac`/`ic` textobjects

## Conventions

- Lua style: tabs, stylua (`.stylua.toml`); `require "x"` call style without parens is common.
- New LSP server: add `vim.lsp.config.<name> = {...}` in `lspconfig.lua` and add it to `all_servers`; add the Mason package to mason-tool-installer if it should auto-install.
- New formatter: add to `formatters_by_ft` in `conform.lua` (and Mason if needed).
- New keymaps: plugin-specific ones go in the plugin spec's `keys` (so they also lazy-load the plugin); global ones in `mappings.lua`.
- `lazy-lock.json` is gitignored.

## File Structure

```
.
├── init.lua                    # Bootstrap and entry point
├── lua/
│   ├── chadrc.lua              # NvChad config (theme, hl overrides)
│   ├── options.lua             # Vim options (tabs, width 4)
│   ├── mappings.lua            # Global + DAP keybindings
│   ├── themes/
│   │   └── rosepine-moon.lua   # Custom base46 theme
│   ├── utils/
│   │   └── venv.lua            # Python interpreter resolver
│   ├── configs/
│   │   ├── lazy.lua            # lazy.nvim options
│   │   ├── lspconfig.lua       # LSP servers (vim.lsp.config)
│   │   ├── conform.lua         # Formatters
│   │   ├── dap.lua             # Debug adapter + launch configs
│   │   ├── treesitter.lua      # Parsers + treesitter start (main branch)
│   │   ├── treesitter-textobjects.lua
│   │   └── rainbow.lua         # Rainbow delimiters
│   └── plugins/
│       └── init.lua            # Plugin specs + Claude pane picker
├── test/
│   ├── run.sh                  # Headless smoke test runner
│   └── smoke.lua               # Smoke test checks
├── README.md                   # Overview and install
├── CONFIG_SUMMARY.md           # Full plugin/keymap reference
├── NOTES_INGEST.md             # Original design doc for notes RAG (now brain-rag)
└── lazy-lock.json              # Plugin version lock (gitignored)
```
