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

install_docker() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		# Debian/Ubuntu 
        info "Installing Docker for Linux..."
        sudo apt-get update
        sudo apt-get install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
        success "Docker has been installed successfully."
        
        info "Verifying Docker installation..."
        if sudo docker run hello-world; then
            success "Docker is working correctly."
        else
            error "Docker installation seems to have issues."
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        info "Installing Docker (via Colima) for macOS..."
        brew install docker
        brew install colima
        success "Docker and Colima have been installed successfully."
        
        info "Starting Colima to verify installation..."
        colima start
        if docker run hello-world; then
            success "Docker is working correctly."
        else
            error "Docker installation seems to have issues."
        fi
        info "Stopping Colima..."
        colima stop
    else
        error "Unsupported OS. Please install Docker manually."
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

if ! command -v docker &> /dev/null; then
	echo -n "Install Docker ? [y/n] "
    read query_docker
	if [[ "$query_docker" == "y" || "$query_docker" == "Y" ]]; then
		install_docker
	else
		error "Please install docker manually."
        exit 1
	fi
fi