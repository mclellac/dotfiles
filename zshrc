source /usr/local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh

HISTFILE=$HOME/.zhistory       # enable history saving on shell exit
setopt APPEND_HISTORY          # append rather than overwrite history file.
HISTSIZE=1200                  # lines of history to maintain memory
SAVEHIST=1000                  # lines of history to maintain in history file.
setopt HIST_EXPIRE_DUPS_FIRST  # allow dups, but expire old ones when I hit HISTSIZE
setopt EXTENDED_HISTORY        # save timestamp and runtime information
export SAVEHIST HISTFILE HISTSIZE
export HISTCONTROL=ignoredups

GOROOT="/usr/local/go"
export GOPATH=$HOME/Projects
export PATH="$PATH:$GOROOT/bin:/usr/local/bin:/bin:/usr/bin:/usr/sbin:/sbin:${HOME}/bin:/Applications/VirtualBox.app/Contents/MacOS/"
export EDITOR=vim
export VISUAL=vim

# digall: List all DNS records for a domain.
digall() { '/usr/bin/dig +nocmd "$*" any +multiline +noall +answer'; }

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
setopt rmstarsilent

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# CTRL+LEFT ARROW  & CTRL+RIGHT ARROW keybinding to  go back or forward 
# a word.
bindkey ';5D' emacs-backward-word
bindkey ';5C' emacs-forward-word

#precmd() {
#    if [[ ( ${-} == *i* ) && ( ${TERM} == screen* ) ]]
#    then
#        echo -n "\ek$(hostname -fs)\e\\"
#    fi
#}

function powerline_precmd() {
    export PS1="$(/usr/lib/powerline/powerline-shell.py $? --shell zsh 2> /dev/null)"
    export SUDO_PS1="$(/usr/lib/powerline/powerline-shell.py $? --shell zsh 2> /dev/null)"
}

function install_powerline_precmd() {
    for s in "${precmd_functions[@]}"; do
        if [ "$s" = "powerline_precmd" ]; then
            return
        fi
    done
    precmd_functions+=(powerline_precmd)
}
install_powerline_precmd
