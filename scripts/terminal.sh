#!/bin/bash

install_nerd_font() {
  local font_dir="$HOME/Library/Fonts"
  local zip_path="$HOME/JetBrainsMono.zip"
  local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"

  mkdir -p "$font_dir"

  if ls "$font_dir"/JetBrainsMonoNerdFont* >/dev/null 2>&1; then
    info "JetBrainsMono Nerd Font already installed."
    return 0
  fi

  info "Downloading JetBrainsMono Nerd Font..."
  curl -fsSL -o "$zip_path" "$font_url"
  unzip -oq "$zip_path" -d "$font_dir"
  rm -f "$zip_path"
  success "JetBrainsMono Nerd Font installed."
}

install_tpm() {
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"
  if [[ -d "$tpm_dir" ]]; then
    info "TPM already installed."
    return 0
  fi

  mkdir -p "$(dirname "$tpm_dir")"
  info "Installing tmux plugin manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  success "TPM installed."
}
