#!/bin/bash

# -- Nerd font --
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

# -- Starship --
if command -v starship &> /dev/null; then
	success "Starship is already installed!"
else
  info "Installing Starship..."
  brew install starship
  if [[ $? -eq 0 ]]; then
    success "Starship has been installed successfully!"
  else
    error "Starship installation failed."
  fi
fi

# -- Ghostty --
if command -v ghostty &> /dev/null; then
	success "Ghostty is already installed!"
else
  info "Installing Ghostty..."
  brew install --cask ghostty
  if [ $? -eq 0 ]; then
    success "Ghostty has been installed successfully!"
  else
    error "Ghostty installation failed."
    return 1
  fi
fi