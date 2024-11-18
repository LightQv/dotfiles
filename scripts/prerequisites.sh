#!/bin/bash

install_homebrew() {
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if ! grep -q 'eval "\$(/opt/homebrew/bin/brew shellenv)"' ~/.bash_profile; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew has been installed successfully."
}

install_git() { 
	info "Installing git..." 
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
		# Debian/Ubuntu 
		sudo apt update && sudo apt install -y git
        success "Git have been installed successfully"
	elif [[ "$OSTYPE" == "darwin"* ]]; then 
		if ! command -v git &> /dev/null; then 
            info "Git is not installed. Installing via Homebrew..." 
            install_homebrew
            brew install git
            success "Git have been installed successfully"
		fi
	else 
		error "Unsupported OS. Please install git manually." 
		return 1 
	fi 
}

if ! command -v brew &> /dev/null; then
    echo -n "Install Homebrew? [y/n] "
    read query_homebrew
    if [[ "$query_homebrew" == "y" || "$query_homebrew" == "Y" ]]; then
        install_homebrew
        . "$HOME/.bash_profile"
    else
        error "Please install Homebrew manually."
        exit 1
    fi
fi

if ! command -v git &> /dev/null; then
	echo -n "Install GIT ? [y/n] "
    read query_git
	if [[ "$query_git" == "y" || "$query_git" == "Y" ]]; then
		install_git
	else
		error "Please install git manually."
        exit 1
	fi
fi
