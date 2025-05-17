# Text editors
export EDITOR=vim
export VISUAL=vim

# Enable colored CLI output on BSD
# export CLICOLOR=1

# Customize less behavior
# -R: enable control chars
# -M: verbose prompt
# -S: disable word wrap
# -K: exit on CTRL-C
export LESS='-RMSK --mouse --wheel-lines=3'
export SYSTEMD_LESS='-RMSK --mouse --wheel-lines=3'

# Make in parallel
export MAKEFLAGS="-j$(nproc)"

[[ -f ~/.bashrc ]] && . ~/.bashrc
