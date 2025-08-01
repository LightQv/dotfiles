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
alias gcommit='git commit -m'            # Git commit with message
alias gpod='git pull origin develop' # Git pull origin develop
alias gpush='git push origin $(git branch --show-current)' # Git push origin current branch
alias gswitch='git switch'                # Git switch shortcut
alias gcb='git checkout -b'          # Git checkout on new branch

# ZSH
alias vzrc='vim "$HOME/.config/zsh/.zshrc"' # Open .zshrc with Vim
alias szrc='. "$HOME/.config/zsh/.zshrc"'  # Source .zshrc

# Starship
alias vship='vim "$HOME/.config/starship/starship.toml"' # Open starship.toml with Vim

# Python
alias python='python3.12'          # For ZSH
alias python3='python3.12'         # Force Python3.12

# Docker
alias dc='docker-compose'          # Docker-compose shortcut

# Lazydocker
alias lzd='lazydocker'             # Lazydocker shortcut