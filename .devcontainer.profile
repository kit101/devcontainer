# java envs
[ -s "$HOME/.jabba/jabba.sh" ] && . "$HOME/.jabba/jabba.sh"

# golang envs
export G_MIRROR=https://go.dev/dl/
export G_HOME="$HOME/.g"
[ -s "$G_HOME/env" ] && . "$G_HOME/env"

# node envs
export N_NODE_MIRROR=https://npmmirror.com/mirrors/node/
export N_PREFIX="$HOME/.nvm"
[[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).