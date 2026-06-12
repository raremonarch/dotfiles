# Use emacs keymap (bash-like, no vi modal editing)
bindkey -e

# Key bindings
bindkey "\e[H" beginning-of-line   # HOME
bindkey "\e[F" end-of-line         # END
bindkey "\e[3~" delete-char        # Delete
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
