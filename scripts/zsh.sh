#!/bin/bash

ZSHRC_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/zsh/.zshrc"
CUSTOM_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/zsh/custom.zsh"
ALIASES_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/zsh/aliases.zsh"
SYNTAX_THEME_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/zsh/themes/syntax-highlighting.zsh"
ZSHENV_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/zsh/.zshenv"

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

download_file "$ZSHRC_URL" "$HOME/.config/zsh/.zshrc"
download_file "$CUSTOM_URL" "$HOME/.config/zsh/custom.zsh"
download_file "$ALIASES_URL" "$HOME/.config/zsh/aliases.zsh"
download_file "$SYNTAX_THEME_URL" "$HOME/.config/zsh/themes/syntax-highlighting.zsh"
download_file "$ZSHENV_URL" "$HOME/.zshenv"

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

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.config/zsh/.zshrc"

clone_repo "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.config/zsh/plugins/zsh-autosuggestions"
clone_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.config/zsh/plugins/zsh-syntax-highlighting"
clone_repo "https://github.com/zsh-users/zsh-completions.git" "$HOME/.config/zsh/plugins/zsh-completions"

## FZF
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