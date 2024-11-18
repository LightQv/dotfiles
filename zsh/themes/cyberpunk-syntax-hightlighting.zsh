# Cyberpunk Theme (for zsh-syntax-highlighting)
#
# Paste this file's contents inside your ~/.zshrc before you activate zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES

# Main highlighter styling: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
#
## General
### Diffs
### Markup
## Classes
## Comments
ZSH_HIGHLIGHT_STYLES[comment]='fg=#606060'  # Dark gray for comments

## Constants
## Entities
## Functions/methods
ZSH_HIGHLIGHT_STYLES[alias]='fg=#00FFFF'  # Neon cyan for alias
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#00FFFF'  # Neon cyan
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#00FFFF'  # Neon cyan
ZSH_HIGHLIGHT_STYLES[function]='fg=#00FFFF'  # Neon cyan for functions
ZSH_HIGHLIGHT_STYLES[command]='fg=#00FFFF'  # Neon cyan for commands
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#00FFFF,italic'  # Neon cyan, italic for precommands
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#FF00FF,italic'  # Neon magenta for autodir
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#FF00FF'  # Neon magenta for options
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#FF00FF'  # Neon magenta
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#FF00FF'  # Neon magenta

## Keywords
## Built ins
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#00FFFF'  # Neon cyan for builtins
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#00FFFF'  # Neon cyan
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#00FFFF'  # Neon cyan

## Punctuation
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#FF00FF'  # Neon magenta for separators
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#FFD700'  # Bright yellow for substitution delimiters
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#FFD700'  # Same yellow for unquoted delimiters
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#FFD700'  # Bright yellow
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#FF00FF'  # Neon magenta
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#FF00FF'  # Neon magenta
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#FF00FF'  # Neon magenta

## Serializable / Configuration Languages
## Storage
## Strings
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=#FFD700'  # Bright yellow for strings
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=#FFD700'  # Bright yellow
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#FFD700'  # Bright yellow
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#FF4500'  # Red-orange for unclosed strings
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#FFD700'  # Bright yellow for double quotes
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#FF4500'  # Red-orange for unclosed double quotes
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#FFD700'  # Bright yellow

## Variables
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#FFD700'  # Bright yellow for variables
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#FF4500'  # Red-orange for unclosed variables
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#FFD700'  # Bright yellow for double-quoted variables
ZSH_HIGHLIGHT_STYLES[assign]='fg=#FFD700'  # Bright yellow for assignments
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#FFD700'  # Bright yellow for file descriptors
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#FFD700'  # Same for numeric FDs

## No category relevant in spec
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF4500'  # Red-orange for unknown tokens
ZSH_HIGHLIGHT_STYLES[path]='fg=#FFD700,underline'  # Bright yellow and underline for paths
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#FF00FF,underline'  # Neon magenta for path separators
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#FFD700,underline'  # Bright yellow with underline for path prefixes
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#FF00FF,underline'  # Neon magenta
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#FFD700'  # Bright yellow for globbing
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#FF00FF'  # Neon magenta for history expansion

#ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=?'
#ZSH_HIGHLIGHT_STYLES[command-substitution-unquoted]='fg=?'
#ZSH_HIGHLIGHT_STYLES[process-substitution]='fg=?'
#ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=?'

ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#FF4500'  # Red-orange for unclosed backquotes
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#FFD700'  # Bright yellow for redirection
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#FFD700'  # Bright yellow for arguments
ZSH_HIGHLIGHT_STYLES[default]='fg=#FFD700'  # Bright yellow for default
ZSH_HIGHLIGHT_STYLES[cursor]='fg=#FFD700'  # Bright yellow cursor
