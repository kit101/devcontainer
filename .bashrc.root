# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'


# java envs
[ -s "/root/.jabba/jabba.sh" ] && . "/root/.jabba/jabba.sh"

# golang envs
export G_MIRROR=https://go.dev/dl/
export G_HOME=/root/.g
[ -s "$G_HOME/env" ] && . "$G_HOME/env"

# node envs
export N_NODE_MIRROR=https://npmmirror.com/mirrors/node/
export N_PREFIX="$HOME/.nvm"
[[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).