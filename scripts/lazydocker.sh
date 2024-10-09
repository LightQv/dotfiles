#!/bin/bash

install_lazydocker() {
    info "Installing Lazydocker..."
    brew install jesseduffield/lazydocker/lazydocker
    if [ $? -eq 0 ]; then
        success "Lazydocker has been installed successfully."
    else
        error "Failed to install Lazydocker."
        return 1
    fi
}

if ! command -v lazydocker &> /dev/null; then
    echo -n "Install Lazydocker? [y/n] "
    read query_lazydocker
    if [[ "$query_lazydocker" == "y" || "$query_lazydocker" == "Y" ]]; then
        install_lazydocker
    fi
fi

LAZYDOCKER_CONF_URL="https://raw.githubusercontent.com/lightqv/dotfiles/lazydocker/config.yml"
LAZYDOCKER_URL="$HOME/Library/Application Support/lazydocker/"

info "Downloading Lazydocker's config.yml..." 
curl -# -o "$LAZYDOCKER_URL/config.yml" "$LAZYDOCKER_CONF_URL" 
if [[ $? -eq 0 ]]; then
    success "Lazydocker's config.yml has been successfully downloaded."
else
    error "Error while downloading Lazydocker's config.yml file."
fi