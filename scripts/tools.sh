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
