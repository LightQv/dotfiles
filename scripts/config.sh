#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

sync_dir() {
  local src="$1"
  local dest="$2"

  mkdir -p "$dest"
  rsync -a --delete "$src/" "$dest/"
}

sync_dotfiles() {
  info "Syncing dotfiles to HOME..."

  sync_dir "$REPO_DIR/.config/nvim" "$HOME/.config/nvim"
  sync_dir "$REPO_DIR/.config/tmux" "$HOME/.config/tmux"
  sync_dir "$REPO_DIR/.config/zsh" "$HOME/.config/zsh"
  sync_dir "$REPO_DIR/.config/starship" "$HOME/.config/starship"
  sync_dir "$REPO_DIR/.config/ghostty" "$HOME/.config/ghostty"
  sync_dir "$REPO_DIR/.config/vim" "$HOME/.config/vim"
  sync_dir "$REPO_DIR/.config/bat" "$HOME/.config/bat"
  sync_dir "$REPO_DIR/.config/opencode" "$HOME/.config/opencode"
  sync_dir "$REPO_DIR/.config/lazygit" "$HOME/.config/lazygit"
  sync_dir "$REPO_DIR/.config/yazi" "$HOME/.config/yazi"
  sync_dir "$REPO_DIR/.config/raycast" "$HOME/.config/raycast"

  cp "$REPO_DIR/.zshenv" "$HOME/.zshenv"
  success "Dotfiles synced."
}

setup_symlinks() {
  ln -sfn "$HOME/.config/vim/.vimrc" "$HOME/.vimrc"
  ln -sfn "$HOME/.config/tmux/.tmux.conf" "$HOME/.tmux.conf"
  success "Symlinks configured (.vimrc and .tmux.conf)."
}

clone_if_missing() {
  local repo_url="$1"
  local dest="$2"

  if [[ -d "$dest" ]]; then
    info "$dest already exists."
    return 0
  fi

  git clone "$repo_url" "$dest"
  success "Installed $(basename "$dest")."
}

install_zsh_plugins() {
  mkdir -p "$HOME/.config/zsh/plugins" "$HOME/.config/zsh/themes"

  clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.config/zsh/plugins/zsh-autosuggestions"
  clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.config/zsh/plugins/zsh-syntax-highlighting"
  clone_if_missing "https://github.com/zsh-users/zsh-completions.git" "$HOME/.config/zsh/plugins/zsh-completions"
  clone_if_missing "https://github.com/marlonrichert/zsh-autocomplete.git" "$HOME/.config/zsh/plugins/zsh-autocomplete"
  clone_if_missing "https://github.com/jimeh/tmuxifier.git" "$HOME/.config/tmux/plugins/tmuxifier"
}
