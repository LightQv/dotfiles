#!/bin/bash

# -- Apps installation --
while read -r cask; do
  if [[ -n "$cask" ]] && ! brew list --cask "$cask" &>/dev/null; then
    info "Installing $cask..."
    brew install --cask "$cask"
  else
    info "$cask already installed."
  fi
done < "$(dirname "$0")/casks.txt"
