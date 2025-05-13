# color
alias ls='ls --color=auto'
alias diff='diff --color=auto'
alias grep='grep --color=auto'

# ls
alias l='ls -alF'
alias ll='ls -alF'
alias sl='ls'
alias s='ls'

# cd
alias fd='cd ..'

# apt (debian)
alias up='sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove --purge && sudo apt-get clean'

# pacman (arch)
# alias up='sudo pacman -Syu && yay -Syua && sudo pacman -Rsn $(pacman -Qdttq) && sudo paccache -r && sudo paccache -urk0'

# pkg (freebsd)
# alias up='sudo pkg upgrade && sudo pkg autoremove && sudo pkg clean'

# wg
alias wgu='wg-quick up wg0'
alias wgd='wg-quick down wg0'

# ssh + tmux
ssht() { ssh -t "$@" 'tmux new -As0'; }
