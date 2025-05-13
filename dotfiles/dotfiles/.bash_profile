# Text editors
export EDITOR=vim
export VISUAL=vim

# Enable colored ls output on BSD
# export CLICOLOR=1

# Make in parallel
export MAKEFLAGS="-j$(nproc)"

[[ -f ~/.bashrc ]] && . ~/.bashrc
