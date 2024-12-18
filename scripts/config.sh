#!/bin/bash

# -- .config --
CONFIG_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/.config"

download_config_folder() {
    local url="$1"
    local dest="$2"
    curl -# -o "$dest" "$url"
    if [[ $? -eq 0 ]]; then
        success "$(basename "$dest") has been successfully downloaded."
    else
        error "Error while downloading $(basename "$dest")."
        return 1
    fi
}

download_config_folder "$CONFIG_URL" "$HOME"

# -- VIM --
if [ -f "$HOME/.vimrc" ]; then
    echo "Deleting existing ~/.vimrc file..."
    rm "$HOME/.vimrc"
fi

echo "Creation of a link from ~/.vimrc to ~/.config/vim/vimrc..."
ln -sf "$HOME/.config/vim/vimrc" "$HOME/.vimrc"

if [[ $? -eq 0 ]]; then
    echo "Link from ~/.vimrc successfully created."
else
    echo "Error while link creation."
fi

# -- zsh --
## zshenv
ZSHENV_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/.zshenv"
mkdir -p "$HOME/.config/zsh/plugins" "$HOME/.config/zsh/themes" "$HOME/.zsh"

download_file() {
    local url="$1"
    local dest="$2"
    curl -# -o "$dest" "$url"
    if [[ $? -eq 0 ]]; then
        success "$(basename "$dest") has been successfully downloaded."
    else
        error "Error while downloading $(basename "$dest")."
        return 1
    fi
}

download_file "$ZSHENV_URL" "$HOME/.zshenv"

## plugins
clone_repo() {
    local repo_url="$1"
    local dest="$2"

    if [ -d "$dest" ]; then
        info "$dest already exists. Skipping clone."
    else
        info "Cloning $(basename "$repo_url")..."
        git clone "$repo_url" "$dest"
        if [[ $? -eq 0 ]]; then
            success "$(basename "$repo_url") has been successfully installed."
        else
            error "Error while installing $(basename "$repo_url")."
            return 1
        fi
    fi
}

clone_repo "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.config/zsh/plugins/zsh-autosuggestions"
clone_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.config/zsh/plugins/zsh-syntax-highlighting"
clone_repo "https://github.com/zsh-users/zsh-completions.git" "$HOME/.config/zsh/plugins/zsh-completions"
clone_repo "https://github.com/marlonrichert/zsh-autocomplete.git" "$HOME/.config/zsh/plugins/zsh-autocomplete"

## fzf
if command -v fzf >/dev/null 2>&1; then
    fzf_path=$(which fzf)
    if [[ -d "$fzf_path" ]]; then
        rm -rf "$fzf_path"
    fi
fi

info "Installing fzf with Homebrew..."
brew install fzf
if [[ $? -eq 0 ]]; then
    success "fzf has been successfully installed."
else
    error "Error while installing fzf."
    return 1
fi

## autojump
if command -v autojump >/dev/null 2>&1; then
    autojump_path=$(which autojump)
    if [[ -d "$autojump_path" ]]; then
        rm -rf "$autojump_path"
    fi
fi

info "Installing autojump..."
brew install autojump
if [[ $? -eq 0 ]]; then
    success "autojump has been successfully installed."
else
    error "Error while installing autojump."
    return 1
fi