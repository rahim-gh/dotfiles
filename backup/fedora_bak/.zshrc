# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt nomatch
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/rahim/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

eval "$(starship init zsh)"

export PATH="$HOME/development/flutter/bin:$HOME/.pub-cache/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export CHROME_EXECUTABLE="$(which chromium-browser)"
#export GRADLE_HOME="$(which gradle)"

alias tor-browser="/opt/tor-browser/Browser/start-tor-browser"
alias telegram="/opt/Telegram/Telegram"
alias syncthing="/opt/syncthing/syncthing"

. "$HOME/.cargo/env"

if [ -e /home/rahim/.nix-profile/etc/profile.d/nix.sh ]; then . /home/rahim/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
