# Use emacs keymap (bash-like, no vi modal editing)
bindkey -e

# Bracketed paste: zsh must handle ^[[200~ / ^[[201~ or they appear as literal text
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Key bindings
bindkey "\e[H" beginning-of-line   # HOME
bindkey "\e[F" end-of-line         # END
bindkey "\e[3~" delete-char        # Delete
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
