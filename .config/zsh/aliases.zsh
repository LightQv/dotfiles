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
alias gpush='git push origin $(git branch --show-current)' # Git push origin current branch

# ZSH
alias vzrc='vim "$HOME/.config/zsh/.zshrc"' # Open .zshrc with Vim
alias szrc='. "$HOME/.config/zsh/.zshrc"'  # Source .zshrc

# Starship
alias vship='vim "$HOME/.config/starship/starship.toml"' # Open starship.toml with Vim

# Kitty's theme
alias kitty_mocha='
    sed -i "" "17s|.*|palette = \"catppuccin_mocha\"|" "$HOME/.config/starship/starship.toml" &&
    
    sed -i "" "2s|.*|#include $HOME/.config/kitty/themes/cyberpunk.conf|" "$HOME/.config/kitty/kitty.conf" &&
    sed -i "" "3s|.*|include $HOME/.config/kitty/themes/mocha.conf|" "$HOME/.config/kitty/kitty.conf" &&

    sed -i "" "8s|.*|[ -f \"$HOME/.config/zsh/themes/mocha-syntax-highlighting.zsh\" ] && source \"$HOME/.config/zsh/themes/mocha-syntax-highlighting.zsh\"|" "$HOME/.config/zsh/.zshrc" &&
    sed -i "" "9s|.*|# [ -f \"$HOME/.config/zsh/themes/cyberpunk-syntax-highlighting.zsh\" ] && source \"$HOME/.config/zsh/themes/cyberpunk-syntax-highlighting.zsh\"|" "$HOME/.config/zsh/.zshrc" &&

    szrc &&
    kitty @ load-config
'

alias kitty_cyberpunk='
    sed -i "" "17s|.*|palette = \"cyberpunk\"|" "$HOME/.config/starship/starship.toml" &&
    
    sed -i "" "2s|.*|#include $HOME/.config/kitty/themes/mocha.conf|" "$HOME/.config/kitty/kitty.conf" &&
    sed -i "" "3s|.*|include $HOME/.config/kitty/themes/cyberpunk.conf|" "$HOME/.config/kitty/kitty.conf" &&

    sed -i "" "8s|.*|# [ -f \"$HOME/.config/zsh/themes/mocha-syntax-highlighting.zsh\" ] && source \"$HOME/.config/zsh/themes/mocha-syntax-highlighting.zsh\"|" "$HOME/.config/zsh/.zshrc" &&
    sed -i "" "9s|.*|[ -f \"$HOME/.config/zsh/themes/cyberpunk-syntax-highlighting.zsh\" ] && source \"$HOME/.config/zsh/themes/cyberpunk-syntax-highlighting.zsh\"|" "$HOME/.config/zsh/.zshrc" &&

    szrc &&
    kitty @ load-config
'

# Docker
alias dc='docker-compose'          # Docker-compose
alias dc='docker compose'          # Docker compose