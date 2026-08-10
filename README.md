## Dotfiles

Bootstrap a fresh macOS machine with one command flow.

```bash
git clone git@github.com:LightQv/dotfiles.git
cd dotfiles
./install.sh
```

What the installer handles:

- Homebrew installation (if missing)
- Brew formulas and casks installation
- Dotfiles sync from this repository into `~/.config`
- `~/.vimrc` and `~/.tmux.conf` symlinks
- TPM bootstrap install
- Zsh plugin clones
- JetBrainsMono Nerd Font install

Manual final steps:

- Open tmux and run `prefix + I` once to install tmux plugins
- Import Tinycast snapshots from `.config/tinycast/Tinycast-Settings.json` and `.config/tinycast/Tinycast-Quicklinks.json` if needed
