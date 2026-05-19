# Git
alias gs='git status'                # Git status shortcut 
alias gaa='git add -A'		     # Git add modified files
alias gcm='git commit -m'            # Git commit with message
alias gpod='git pull origin develop' # Git pull origin develop
alias gpush='git push origin $(git branch --show-current)' # Git push origin current branch
alias gsw='git switch'                # Git switch shortcut
alias gcb='git checkout -b'          # Git checkout on new branch

# ZSH
alias vzrc='vim "$HOME/.config/zsh/.zshrc"' # Open .zshrc with Vim
alias szrc='. "$HOME/.config/zsh/.zshrc"'  # Source .zshrc
alias vvrc='vim "$HOME/.config/vim/.vimrc"' # Open .vimrc with Vim
alias svrc='. "$HOME/.config/vim/.vimrc"'  # Source .vimrc

# Starship
alias vship='vim "$HOME/.config/starship/starship.toml"' # Open starship.toml with Vim

# Docker
alias dc='docker-compose'          # Docker-compose
alias dcr='dc down && dc up --build -d'          # Docker-compose down up rebuild

# Python
alias python='python3.12'          # Pour ZSH
alias python3='python3.12'         # Force Python3.12

# Eza
alias ls='eza -1 --group-directories-first --classify=always -1 --icons --long'
alias lsr='ls -R --level=2'

# Fzf
alias fp='fzf --style full --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}''

# Zoxyde
if [[ "$CLAUDECODE" != "1" ]]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Nvim
alias v='nvim'

# Opencode
alias oc='opencode'

# Tmux
alias t="tmux"
alias tl="tmux ls"
alias td="tmux detach"
ta() {
    if [ "$#" -eq 0 ]; then
        tmux attach
    else
        tmux attach -t "$1"
    fi
}
tk() {
    tmux kill-session -t "$1"
}

# Tmuxifier
alias tls="tmuxifier load-session"
