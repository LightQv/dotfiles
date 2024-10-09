# Directory
alias ..='cd ..'                     # Go to parent directory
alias ...='cd ../..'                 # Go to grandparent directory
alias ~='cd ~'                       # Go to home directory
alias cd..='cd ..'                   # Correct a common typo

# Files list
alias l='ls -l'                      # Detailed list
alias la='ls -A'                     # List with hidden files
alias ll='ls -la'                    # Detailed list with hidden files
alias ls='ls --color=auto'           # Colorized ls (if supported)

# Git
alias gs='git status'                # Git status shortcut 
alias gcm='git commit -m'            # Git commit with message

# ZSH
alias zrc='vim "$HOME/.config/zsh/.zshrc"' # Open .zshrc with Vim
alias szrc='. "$HOME/.config/zsh/.zshrc"'  # Source .zshrc