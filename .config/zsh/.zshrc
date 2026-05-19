# Custom zsh
[ -f "$HOME/.config/zsh/custom.zsh" ] && source "$HOME/.config/zsh/custom.zsh"

# Aliases
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# Themes
[ -f "$HOME/.config/zsh/themes/mocha-syntax-highlighting.zsh" ] && source "$HOME/.config/zsh/themes/mocha-syntax-highlighting.zsh"

. "$HOME/.local/bin/env"

# opencode
export PATH=/Users/vivianquerenet/.opencode/bin:$PATH
