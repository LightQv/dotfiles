#!/bin/bash

VIMRC_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/vim/.vimrc"

info "Downloading .virmrc..." 
curl -# -o "$HOME/.vimrc" "$VIMRC_URL"
if [[ $? -eq 0 ]]; then
    success "Vim has been successfully installed."
else
    error "Error while downloading .vimrc file."
fi