# Text editors
export EDITOR=vim
export VISUAL=vim

# Enable mouse scroll and word wrap on journalctl
export SYSTEMD_LESS=FRMK
export LESS=-FRMK

# Make in parallel
export MAKEFLAGS="-j$(nproc)"

[[ -f ~/.bashrc ]] && . ~/.bashrc
