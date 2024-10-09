# Plugins
source $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath+=(~/.config/zsh/plugins/zsh-completions)

# Plugins theme
source $HOME/.config/zsh/plugins/themes/zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh