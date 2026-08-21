# Zsh plugins
source $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath+=(~/.config/zsh/plugins/zsh-completions)
source $HOME/.config/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# Fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# Lazydocker
export LAZYDOCKER_CONFIG_DIR="$HOME/.config/lazydocker"

# Lazygit
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"

# Force brew python use
export PATH="/opt/homebrew/opt/python@3.12/bin:$PATH"

# Opencode
export EDITOR=nvim

# Tmuxifier
export PATH="$HOME/.config/tmux/plugins/tmuxifier/bin:$PATH"
export TMUX_CONF="$HOME/.config/tmux/.tmux.conf"
export TMUXIFIER_LAYOUT_PATH="$HOME/.config/tmux/tmuxifier/layouts"
eval "$(tmuxifier init -)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
