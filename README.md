## Dotfiles

Bootstrap a fresh macOS machine with one command flow. Requires an internet connection and the Xcode Command Line Tools so Git is available (`xcode-select --install`); Homebrew is installed automatically if missing.

```bash
git clone https://github.com/LightQv/dotfiles.git
cd dotfiles
./install.sh
```

What the installer handles:

- Homebrew installation (if missing)
- Brew formulas and casks installation
- Dotfiles sync from this repository into `~/.config`
- Portable OpenCode config, generic agents, commands, skills, and RTK integration
- `~/.vimrc` and `~/.tmux.conf` symlinks
- TPM bootstrap install
- Zsh plugin clones
- JetBrainsMono Nerd Font install

Manual final steps:

- Open tmux and run `prefix + I` once to install tmux plugins
- Import Tinycast snapshots from `.config/tinycast/Tinycast-Settings.json` and `.config/tinycast/Tinycast-Quicklinks.json` if needed

Most managed config directories mirror the repository, while OpenCode uses a non-deleting overlay. Sync exclusions preserve local tmuxifier layouts, OpenCode notification plugins and OCX state, plugin checkouts, shell history, and Neovim Git metadata.
