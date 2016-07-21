#!/usr/bin/env bash
#--
# Install script for github.com/mclellac dotfiles
# Usage:
#    bash <(curl -s https://raw.githubUSERcontent.com/mclellac/dotfiles/master/install.sh -L)
#--
DOTCONFIG="${HOME}/.config"
DOTDIR="${DOTCONFIG}/dotfiles"
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
PACKAGE_LIST="/tmp/missing-packages.txt"
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)
WHITE=$(tput setaf 7)
RED=$(tput setaf 1)
GREY="$(tput bold ; tput setaf 0)"

separator()  { printf $GREY'%.0s-'$WHITE {1..79}; echo; }
cmd_exists() { [ -x "$(command -v "$1")" ] && printf 0 || printf 1; }

check_deps() {
    separator
    printf "Checking to see if the following applications have been installed:\n"

    for (( i=0; i<=(($LEN -1)); i++)); do
        if [ $(cmd_exists ${DEPS[$i]}) -eq 0 ]; then
            printf "${GREEN}[✔]${WHITE} ${DEPS[$i]}\n"
        else
            printf "${RED}[✘] ${DEPS[$i]}${WHITE} is missing.\n"
            echo ${DEPS[$i]} >> $PACKAGE_LIST
        fi
    done

    #--
    # check to see if powerline-zsh & prezto are available & install or update
    # them as needed.
    #--     
    github_grab ${DOTCONFIG}/carlcarl carlcarl powerline-zsh
    github_grab ${HOME}/.zprezto sorin-ionescu prezto.git

    # install powerline fonts.
    github_grab ${DOTCONFIG}/powerline-fonts powerline fonts && sh ${DOTCONFIG}/powerline-fonts/install.sh 

    # if package list exists, then install else symlink conf files.
    [ -f $PACKAGE_LIST ] && install_deps || symlink_dotfiles
}

get_os() {
    OS=`uname -s`

    if [ $OS == 'Darwin' ]; then
        APP_INSTALL="brew install"
        [ ! -f ${HOME}/.zsh.osx ] && touch ${HOME}/.zsh.osx
    elif [ $OS == 'FreeBSD' ]; then
        BSD_INSTALL="cd /usr/ports/devel/"
        [ ! -f ${HOME}/.zsh.bsd ] && touch ${HOME}/.zsh.bsd
    elif [ $OS == 'Linux' ]; then
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

    if [ ! -d ${LOCALDIR} ]; then
        separator
        printf "Cloning: https://github.com/${CYAN}${USER}${WHITE}/${CYAN}${REPOSITORY}${WHITE} to ${CYAN}${LOCALDIR}${WHITE}\n"
        git clone https://github.com/${USER}/${REPOSITORY} ${LOCALDIR}
    else
        separator
        printf "Updating: ${CYAN}${REPOSITORY}${WHITE} in ${CYAN}${LOCALDIR}${WHITE}\n"
        cd ${LOCALDIR} && git pull
    fi

    # if zpresto has been installed, then update the submodules.
    if [ $REPOSITORY = 'prezto.git' ]; then
        separator
        cd ${HOME}/.zprezto
        echo "Updating: ${CYAN}${REPOSITORY}${WHITE} with ${CYAN}git pull && git submodule update --init --recursive${WHITE}"
        git pull && git submodule update --init --recursive
    fi
}

install_deps() {
    separator
    
    printf "${CYAN}Attempting to install missing packages.${WHITE}\n"
    for PACKAGE in `(cat ${PACKAGE_LIST})`; do
        if [ $OS != "FreeBSD" ]; then
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
            printf "${WHITE}DIRECTORY: ${CYAN}${DIRECTORY} ${WHITE}created.\n" || \
            printf "${RED}Error: ${WHITE}Failed to create ${RED}${DIRECTORY} ${WHITE}directory.\n"
    fi
}

vim_setup() {
    for DIRECTORY in ${DIR[@]}; do
        make_dir $DIRECTORY
    done

    github_grab ${HOME}/.vim/bundle/Vundle.vim gmarik vundle.git

    printf "${WHITE}Installing vim plugins: ${CYAN} vim +PluginInstall +qall${WHITE}\n"
    sleep 1
    vim +PluginInstall +qall

    separator
}

symlink_dotfiles() {
    # $SOFTLINK variable stores the absolute path for the symlink
    for FILE in `(find $DOTDIR -mindepth 2 -maxdepth 2 -type f -not -path '\(.*)' | grep -vE '(jhbuild|i3|img|irssi|git|weechat)')`; do
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

    if [ $OS == 'Linux' ]; then
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

separator

# check to make sure ~/.conf directory exists
[ -d ${DOTCONFIG} ] && echo "Using: ${CYAN}${DOTCONFIG}${WHITE}" || make_dir DIRECTORY=${DOTCONFIG}

# check for ~/.zprivate file, create default if doesn't exist.
[ ! -f ${HOME}/.zprivate ] && printf "#-- private variables --\nexport email=\"\"\nexport work_email=\"\"\n" >> .zprivate

# clone or pull project from git
github_grab $DOTCONFIG/dotfiles mclellac dotfiles

get_os
check_deps

printf "Install Complete.\n** Don't forget to manually set your name and email variables in: ${CYAN}${HOME}/.gitconfig${WHITE} **\n"

