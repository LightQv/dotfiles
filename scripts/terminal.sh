#!/bin/bash

## Nerd font
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"

info "Create a Font directory if it doesn't exist."
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"

info "Downloading JetBrainsMono Nerd Font..."
curl -# -L -o "$HOME/JetBrainsMono.zip" "$NERD_FONT_URL"
if [ $? -eq 0 ]; then
	info "Unzipping the font files..."
	unzip -oq "$HOME/JetBrainsMono.zip" -d "$FONT_DIR"
	if [ $? -eq 0 ]; then
		success "JetBrainsMono Nerd Font has been installed successfully!"
		rm "$HOME/JetBrainsMono.zip"
	else
		error "Failed to unzip JetBrainsMono Nerd Font."
		return 1
	fi
else
	error "Failed to download JetBrainsMono Nerd Font."
	return 1
fi

## Starship
starship --version
if [[ $? -eq 0 ]]; then
    rm -f "$HOME/.config/starship.toml"
    brew reinstall starship
fi

info "Installing Starship..."
brew install starship
if [[ $? -eq 0 ]]; then
	success "Starship has been installed successfully!"
else
	error "Kitty installation failed."
fi

STARSHIP_TOML_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/starship/starship.toml"
mkdir -p "$HOME/.config/starship"
info "Downloading starship.toml..."
curl -# -o "$HOME/.config/starship/starship.toml" "$STARSHIP_TOML_URL"
if [[ $? -eq 0 ]]; then
    success "starship.toml has been successfully downloaded."
else
    error "Error while downloading starship.toml file."
fi

## Kitty
info "Installing Kitty..."
curl -# -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
if [ $? -eq 0 ]; then
	success "Kitty has been installed successfully!"
else
	error "Kitty installation failed."
	return 1
fi

mkdir -p "$HOME/.config/kitty"

KITTY_CONF_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/kitty/kitty.conf"
info "Downloading kitty.conf..."
curl -# -o "$HOME/.config/kitty/kitty.conf" "$KITTY_CONF_URL"
if [[ $? -eq 0 ]]; then
    success "kitty.conf has been successfully downloaded."
else
    error "Error while downloading kitty.conf file."
fi

mkdir -p "$HOME/.config/kitty/themes"

MOCHA_KITTY_THEME_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/kitty/themes/mocha.conf"
info "Downloading mocha.conf..."
curl -# -o "$HOME/.config/kitty/themes/mocha.conf" "$MOCHA_KITTY_THEME_URL"
if [[ $? -eq 0 ]]; then
    success "mocha.conf has been successfully downloaded."
else
    error "Error while downloading mocha.conf file."
fi

CYBERPUNK_KITTY_THEME_URL="https://raw.githubusercontent.com/lightqv/dotfiles/main/kitty/themes/cyberpunk.conf"
info "Downloading cyberpunk.conf..."
curl -# -o "$HOME/.config/kitty/themes/cyberpunk.conf" "$CYBERPUNK_KITTY_THEME_URL"
if [[ $? -eq 0 ]]; then
    success "cyberpunk.conf has been successfully downloaded."
else
    error "Error while downloading cyberpunk.conf file."
fi
