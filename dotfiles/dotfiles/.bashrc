# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Bash prompt
PS1='[\u@\h:\w]\n\$ '

# Different file for history so that failing to source this
# file doesn't clobber the full history
HISTFILE=~/.bash_history_real

# Infinite Bash history
HISTFILESIZE=
HISTSIZE=

# Immediately write history
shopt -s histappend
HISTCONTROL=ignoredups
PROMPT_COMMAND="history -a"

# Timestamped history
HISTTIMEFORMAT="%F %T "

# Recursive glob
shopt -s globstar

# Alias definitions
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
