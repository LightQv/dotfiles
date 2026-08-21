---
name: neovim-config
description: Use when editing or troubleshooting Neovim, init.lua, Lua modules, lazy.nvim, LSP, completion, Treesitter, formatters, linters, keymaps, diagnostics, plugins, or headless checks.
---

# Neovim Configuration

## Authority

The existing Neovim configuration, plugin lockfile, plugin manager, local conventions, and installed Neovim version are the source of truth. Use `:help` and official Neovim/plugin documentation matching installed versions when local intent is absent. Never replace the plugin manager or restructure the configuration unless requested.

## Discovery

1. Locate `init.lua`, `lua/`, `after/`, `ftplugin/`, plugin specs, lockfiles, and project-local `.nvim.lua` files.
2. Detect Neovim version and plugin manager before changing APIs.
3. Trace module loading and plugin lazy-load events before moving declarations.
4. Preserve current keymap, option, autocmd, diagnostic, LSP, completion, formatter, and linter conventions.

## Standards

- Keep modules focused; avoid hidden global state and unnecessary startup work.
- Use `vim.keymap.set`, named augroups, and clear keymap descriptions.
- Use current `vim.lsp` APIs supported by installed Neovim; do not mix deprecated setup patterns into modern configs.
- Keep server installation, server configuration, completion capabilities, and formatting ownership distinct.
- Avoid multiple formatters or LSP clients racing to format the same buffer.
- Scope autocmds and clear their augroup on reload.
- Lazy-load plugins only when it does not break commands, mappings, filetypes, or dependencies.
- Keep plugin specs pinned through the repository's lockfile and follow the existing update policy.
- Treat plugin code and remote install/update hooks as executable supply-chain input.

## Completion Gate

1. Format changed Lua files with the configured formatter, commonly StyLua.
2. Run the configured Lua linter/type checker, commonly Luacheck or lua-language-server diagnostics.
3. Start the config headlessly with the repository's command or `nvim --headless "+qa"`.
4. Run targeted module/plugin checks and `:checkhealth` when relevant. Capture failures without hiding them.
5. Test changed mappings, autocmds, LSP attachment, formatter selection, or plugin loading when headless checks cannot prove behavior.
6. Do not run plugin upgrades, lockfile updates, external downloads, or destructive cleanup unless requested.

Report exact commands and any version-specific assumptions. Do not claim completion while required checks fail.
