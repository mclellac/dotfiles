#!/usr/bin/env bash
#--
# Install script for github.com/mclellac dotfiles
# Usage:
#    bash <(curl -s https://raw.githubusercontent.com/mclellac/dotfiles/master/install.sh -L)
#--
DOTCONFIG="${HOME}/.config"
DOTDIR="${DOTCONFIG}/dotfiles"
PACKAGE_LIST="/tmp/missing-packages.txt"
# global colour variables
GREY="$(tput bold ; tput setaf 0)"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
YELLOW=$(tput setaf 11)
BLUE=$(tput setaf 68)
BROWN=$(tput setaf 130)
ORANGE=$(tput setaf 172)
RESET=$(tput sgr0)

declare -a DIR=(
    ${HOME}/.vim
    ${HOME}/.vim/bundle
    ${HOME}/.vim/autoload
    ${HOME}/.vim/colors
    ${HOME}/.vim/backup
)

declare -a DEPS=(
    vim 
    git 
    tmux
)
LEN=${#DEPS[*]}

error_quit()    { message_error $err; exit 1; }
message_ok()    { message=${@:-"[✘]: No OK content"};     printf "${GREEN}[✔] ${message}${RESET}\n"; }
message_error() { message=${@:-"[✘]: No error content"};  printf "${RED}[✘] ${message}${RESET}\n";   }
cmd_exists()    { [ -x "$(command -v "$1")" ] && printf 0 || printf 1; }

check_deps() {
    msg_box "Checking to see if the following applications have been installed"

    for (( i=0; i<=(($LEN -1)); i++)); do
        if [ $(cmd_exists ${DEPS[$i]}) -eq 0 ]; then
            printf "${GREEN}[✔]${RESET} ${DEPS[$i]}\n"
        else
            printf "${RED}[✘] ${DEPS[$i]}${RESET} is missing.\n"
            echo ${DEPS[$i]} >> $PACKAGE_LIST
        fi
    done

    # if package list exists, then install else symlink conf files.
    [ -f $PACKAGE_LIST ] && install_deps || symlink_dotfiles
}

get_os() {
    if [[ $OSTYPE == 'darwin'* ]]; then
        APP_INSTALL="brew install"
        [ ! -f ${HOME}/.zsh.osx ] && touch ${HOME}/.zsh.osx
    elif [[ $OSTYPE == 'freebsd'* ]]; then
        BSD_INSTALL="cd /usr/ports/devel/"
        [ ! -f ${HOME}/.zsh.bsd ] && touch ${HOME}/.zsh.bsd
    elif [[ $OSTYPE == 'linux-gnu' ]]; then
        [ ! -f ${HOME}/.zsh.gnu ] && touch ${HOME}/.zsh.gnu
        if [ $(cmd_exists apt-get) ]; then 
            APP_INSTALL="sudo apt-get install"
        elif [ $(cmd_exists yum) ]; then 
            APP_INSTALL="sudo yum install"
        elif [ $(cmd_exists up2date) ]; then 
            APP_INSTALL="sudo up2date -i"
        else
            printf "${RED}[✘] ${WHITE}No package manager found for this Linux system!\n"
            exit 2
        fi
    else
        printf "${RED}[✘] ${WHITE}Unable to determine the operating system.\n"
        exit 2
    fi
}

# github_grab function takes 3 arguments $LOCALDIR, $USER, $REPOSITORY 
github_grab() {
    LOCALDIR=$1
    USER=$2
    REPOSITORY=$3

    msg_box "Github: $USER/$REPOSITORY"

    if [ ! -d ${LOCALDIR} ]; then   
        printf "Cloning: https://github.com/${CYAN}${USER}${RESET}/${CYAN}${REPOSITORY}${RESET} to ${CYAN}${LOCALDIR}${RESET}\n"
        git clone --recursive https://github.com/${USER}/${REPOSITORY} ${LOCALDIR}
    else
        printf "Updating: ${CYAN}${REPOSITORY}${RESET} in ${CYAN}${LOCALDIR}${RESET}\n"
        cd ${LOCALDIR} && git pull
    fi
}

install_deps() {    
    msg_box "Attempting to install missing packages."
    for PACKAGE in `(cat ${PACKAGE_LIST})`; do
        if [[ $OSTYPE != "freebsd"* ]]; then
            $APP_INSTALL $PACKAGE
        else
            $BSD_INSTALL $PACKAGE && make && sudo make install
        fi
    done
    
    # delete /tmp/missing-packages.txt when done
    rm $PACKAGE_LIST

    symlink_dotfiles
}

make_dir() {
    if [ ! -d $DIRECTORY ]; then 
        mkdir -p $DIRECTORY >/dev/null 2>&1 && \
            printf "${RESET}DIRECTORY: ${CYAN}${DIRECTORY} ${RESET}created.\n" || \
            printf "${RED}Error: ${RESET}Failed to create ${RED}${DIRECTORY} ${RESET}directory.\n"
    fi
}

msg_box() {
    local term_width=80  # this should be dynamic with: term_width=`stty size | cut -d ' ' -f 2`
    local str=("$@") msg_width

    printf '\n'
    
    for line in "${str[@]}"; do
        ((msg_width<${#line})) && { msg_width="${#line}"; }

        if [ $msg_width -gt $term_width ]; then
            error_quit "error: msg_box() >> \$msg_width exceeds \$term_width. Split message into multiple lines or decrease the number of characters.\n"
        fi

        x=$(($term_width - $msg_width))
        pad=$(($x / 2))
    done
    
    # draw box
    printf '%s┌' "${ORANGE}" && printf '%.0s─' {0..79} && printf '┐\n' && printf '│%79s │\n'
    
    for line in "${str[@]}"; do
        rpad=$((80 - $pad - $msg_width)) # make sure to close with width 80
        printf "│%$pad.${pad}s" && printf '%s%*s' "$YELLOW" "-$msg_width" "$line" "${ORANGE}" && printf "%$rpad.${rpad}s│\n"
    done
    
    printf '│%79s │\n' && printf  '└' && printf '%.0s─' {0..79}  && printf '┘\n%s' ${RESET}
}

vim_setup() {
    for DIRECTORY in ${DIR[@]}; do
        make_dir $DIRECTORY
    done

    github_grab ${HOME}/.vim/bundle/Vundle.vim gmarik vundle.git

    printf "${RESET}Installing vim plugins: ${CYAN} vim +PluginInstall +qall${RESET}\n"
    sleep 1
    vim +PluginInstall +qall
}

symlink_dotfiles() {
    msg_box "Symlinking files to $HOME"

    for FILE in `(find $DOTDIR -mindepth 2 -maxdepth 2 -type f -not -path '\(.*)' | grep -vE '(iterm2|jhbuild|i3|img|irssi|git|weechat)')`; do
        # SOFTLINK variable stores the absolute path for the symlink
        SOFTLINK=${HOME}/.`(echo ${FILE} | awk -F/ '{print $7}')`

        if [ ! -f ${SOFTLINK} ]; then
            ln -s ${FILE} ${SOFTLINK}
        else 
            rm ${SOFTLINK} && ln -s ${FILE} ${SOFTLINK}
        fi
    done

    # copy git config files into $HOME, as we don't want them symlinked and mistakenly git pushed
    for FILE in `(ls ${DOTDIR}/git)`; do
        cp ${DOTDIR}/git/$FILE ${HOME}/.${FILE}
    done
    
    # copy weechat config files into $HOME/.weechat
    [ ! -d ${HOME}/.weechat ] && mkdir ${HOME}/.weechat

    for FILE in `(ls ${DOTDIR}/weechat)`; do
        cp ${DOTDIR}/weechat/$FILE ${HOME}/.weechat/${FILE}
    done

    if [[ $OSTYPE == 'linux-gnu' ]]; then
        if [ -d ${HOME}/.i3 ]; then
            mv ${HOME}/.i3 ${HOME}/.i3.old && mkdir -p ${HOME}/.i3
        else 
            mkdir -p ${HOME}/.i3
        fi
        
        ln -s ${DOTDIR}/i3/config ${HOME}/.i3/config
        ln -s ${DOTDIR}/i3/i3blocks.conf ${HOME}/.i3/i3blocks.conf
        cp -R ${DOTDIR}/i3/scripts ${HOME}/.i3/scripts
    fi

    vim_setup
}

# check to make sure ~/.conf directory exists
[ -d ${DOTCONFIG} ] && msg_box "Using: ${DOTCONFIG}" || make_dir DIRECTORY=${DOTCONFIG}

# check for ~/.zprivate file, create default if doesn't exist.
[ ! -f ${HOME}/.zprivate ] && printf "#-- private variables --\nexport email=\"\"\nexport work_email=\"\"\n" >> .zprivate

# clone or pull project from git
github_grab $DOTCONFIG/dotfiles mclellac dotfiles

get_os
check_deps


# if Zim framework doesn't exist, get it
github_grab ${HOME}/.zim Eriner zim.git

# install powerline fonts.
github_grab ${DOTCONFIG}/powerline-fonts powerline fonts && sh ${DOTCONFIG}/powerline-fonts/install.sh 

msg_box "Installation complete."
printf "** Don't forget to manually set your name and email variables in: ${CYAN}${HOME}/.gitconfig${RESET} **\n"

