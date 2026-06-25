# Set terminal window title to the running command (preexec) or "zsh" at prompt (precmd).
# Alacritty's dynamic_title (on by default) picks this up and propagates it to Niri,
# so waybar can display "alacritty:top" etc.
preexec() { printf '\e]0;%s\a' "${${(z)1}[1]:t}" }
precmd()   { printf '\e]0;zsh\a' }
