clear

export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="ar-round"
plugins=(
  git 
  zsh-autosuggestions 
  zsh-syntax-highlighting 
  bgnotify
  zsh-fzf-history-search
)

PATH="$PREFIX/bin:$HOME/.local/bin:$PATH"
export PATH

LINK="https://github.com/mayTermux"
export LINK

LINK_SSH="git@github.com:mayTermux"
export LINK_SSH

export TERM=xterm-256color 
unset DBUS_SESSION_BUS_ADDRESS

source $ZSH/oh-my-zsh.sh
source $HOME/.config/lf/icons
source $HOME/.aliases
source $HOME/.autostart
