# AGENTS.md

This file provides guidance to OpenCode when working with code in this repository.

## Overview

This is a personal Neovim configuration using lazy.nvim as the plugin manager. The configuration is organized under the `lua/light/` namespace.

## Architecture

### Bootstrap & Entry Point

- `init.lua` - Entry point that loads core config and lazy.nvim
- `lua/light/core/init.lua` - Loads options and keymaps
- `lua/light/lazy.lua` - Sets up lazy.nvim and imports plugins from `light.plugins` and `light.plugins.lsp`

### Plugin Organization

Plugins are organized into individual files in `lua/light/plugins/`:

- Each plugin file returns a lazy.nvim plugin spec (a table with plugin config)
- LSP-related plugins are in `lua/light/plugins/lsp/` subdirectory
- Plugins are auto-loaded via lazy.nvim's import mechanism

### Core Configuration

- `lua/light/core/options.lua` - Vim options (tabs, clipboard, split behavior, etc.)
- `lua/light/core/keymaps.lua` - Global keymaps not tied to specific plugins

## Key Technologies

### LSP Setup

- **Mason** (`mason.lua`) - Manages LSP server installations
  - Auto-installs: `html`, `cssls`, `lua_ls`, `basedpyright`, `vue_ls`, `vtsls`
  - Also installs formatters/linters: `prettier`, `eslint_d`, `stylua`, `ruff`
- **LSP Config** (`lspconfig.lua`) - Sets up language servers with custom configurations
  - Uses `blink.cmp` for LSP capabilities
  - Custom configurations for Lua (lua_ls), Python (basedpyright), and Vue/TypeScript (vtsls + vue_ls)
  - Vue support requires TypeScript plugin integration

### Completion

- Uses **blink.cmp** (`completions.lua`) - Modern completion engine
- Note: nvim-cmp was completely removed (per git history)
- Sources: LSP, snippets, buffer, path
- Custom keymaps: `<C-j>`/`<C-k>` for navigation, `<CR>` to accept

### Formatting & Linting

- **conform.nvim** (`formatting.lua`) - Formatting with format-on-save enabled
  - Prettier for JS/TS/Vue/CSS/HTML/JSON/YAML/Markdown
  - stylua for Lua
  - ruff_format for Python
- **nvim-lint** (`linter.lua`) - Linting with eslint_d for JS/TS/Vue
  - Auto-lints on BufEnter, BufWritePost, InsertLeave

### File Navigation

- **Telescope** (`telescope.lua`) - Fuzzy finder
  - Integrates with Trouble for quickfix management (`<C-q>` sends to Trouble)
  - Custom action: `<C-q>` sends results to quickfix and opens Trouble
- **Neo-tree** (`file-tree.lua`) - File explorer
  - Uses mini.icons for icons (via custom provider)
  - `<leader>e` toggles, `<leader>o` toggles focus

### UI Enhancements

- **which-key** (`which-key.lua`) - Displays keybind hints with leader groups
- **mini.icons** - Used throughout for icons (replaces nvim-web-devicons)
- **Trouble** (`trouble.lua`) - Pretty diagnostics/quickfix lists

## Common Development Commands

### Plugin Management

```vim
:Lazy                " Open lazy.nvim UI
:Lazy sync           " Install/update/clean plugins
:Lazy clean          " Remove unused plugins
```

### LSP Management

```vim
:Mason               " Open Mason UI for LSP/tool management
:LspRestart          " Restart LSP (mapped to <leader>ls)
```

### Formatting/Linting

```vim
:ConformInfo         " Show formatter info for current buffer
```

## Important Conventions

### Leader Key Prefixes

The configuration uses a structured leader key system (defined in which-key):

- `<leader>b` - Buffers
- `<leader>f` - Find (Telescope)
- `<leader>g` - Git
- `<leader>h` - Git signs (Gitsigns)
- `<leader>l` - LSP actions
- `<leader>m` - Mobile (formatting)
- `<leader>n` - Notifications
- `<leader>s` - Splits
- `<leader>x` - Trouble
- `<leader>d` - Diagnostics
- `<leader>1-9` - Jump to buffer by index

### LSP Keymaps (available when LSP attaches)

- `gd` - Go to definition
- `gD` - Go to definition in split (custom handler that reuses/creates vsplit)
- `gr` - Show references (Telescope)
- `gI` - Show implementations (Telescope)
- `gt` - Show type definitions (Telescope)
- `K` - Hover documentation
- `<leader>la` - Code actions
- `<leader>lr` - Rename
- `<leader>ld` - Show line diagnostics (focusable)
- `[d` / `]d` - Previous/next diagnostic

### Treesitter

Parsers are auto-installed for: JSON, YAML, JS, TS, HTML, CSS, Vue, Markdown, Bash, Lua, Vim, Dockerfile, Python, Gitignore, C, Rust

### Special Notes

- Tabs are set to 2 spaces width but **NOT expanded** (`expandtab = false`)
- System clipboard is integrated (`clipboard = "unnamedplus"`)
- Swapfiles are disabled
- Format-on-save is enabled globally (3s timeout)
- The config ignores `__init__.py` in Telescope searches by default

### Custom LSP Behavior

- **Open definition in split** (`gD`): Intelligently reuses existing vertical splits or creates new ones
- **Telescope LSP integration**: Custom functions check if results exist before opening Telescope pickers (for implementations and type definitions)
- **Vue + TypeScript**: Uses both vtsls and vue_ls with TypeScript plugin integration for full Vue 3 support

### Mini.nvim Integration

The config uses mini.icons throughout and mocks nvim-web-devicons for compatibility with other plugins.

## File Structure Pattern

When adding new plugins:

1. Create a new file in `lua/light/plugins/` (or `lua/light/plugins/lsp/` for LSP-related)
2. Return a lazy.nvim plugin spec table
3. Plugin will be auto-loaded via lazy.nvim's import system
4. Add relevant leader key groups to `which-key.lua` if creating new key prefix
