#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/scripts/utils.sh"
. "$SCRIPT_DIR/scripts/prerequisites.sh"
. "$SCRIPT_DIR/scripts/tools.sh"
. "$SCRIPT_DIR/scripts/terminal.sh"
. "$SCRIPT_DIR/scripts/config.sh"

ensure_homebrew
install_formula_packages
install_cask_packages
install_nerd_font
install_tpm
sync_dotfiles
setup_symlinks
install_zsh_plugins

success "Bootstrap complete. Restart shell, run tmux, then press prefix + I once for TPM plugins."
info "Raycast profile import remains manual: .config/raycast/profile.rayconfig"
