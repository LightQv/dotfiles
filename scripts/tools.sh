#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_formula_packages() {
  while read -r formula; do
    [[ -z "$formula" || "$formula" =~ ^# ]] && continue
    if brew list "$formula" >/dev/null 2>&1; then
      info "$formula already installed."
    else
      info "Installing $formula..."
      brew install "$formula"
      success "$formula installed."
    fi
  done < "$SCRIPT_DIR/formulas.txt"
}

ensure_tinycast_tap() {
  if brew tap | grep -qx "abue-ammar/tinycast"; then
    info "Tinycast Homebrew tap already configured."
    return 0
  fi

  info "Configuring Tinycast Homebrew tap..."
  brew trust --tap abue-ammar/tinycast
  brew tap abue-ammar/tinycast
  success "Tinycast Homebrew tap configured."
}

install_cask_packages() {
  while read -r cask; do
    [[ -z "$cask" || "$cask" =~ ^# ]] && continue
    if brew list --cask "$cask" >/dev/null 2>&1; then
      info "$cask already installed."
    else
      info "Installing $cask..."
      brew install --cask "$cask"
      success "$cask installed."
    fi
  done < "$SCRIPT_DIR/casks.txt"
}
