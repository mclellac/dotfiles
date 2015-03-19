#!/usr/bin/env bash
#--
# install script for github.com/mclellac dotfiles
# Usage:
#    sh <(curl -s https://raw.githubusercontent.com/mclellac/dotfiles/master/install.sh -L)
#--
dotconfig="${HOME}/.config"
dotdir="${dotconfig}/dotfiles"
declare -a dir=(
    ${HOME}/.vim
    ${HOME}/.vim/bundle
    ${HOME}/.vim/autoload
    ${HOME}/.vim/colors
    ${HOME}/.vim/backup
)
declare -a deps=(
    vim 
    git 
    hg
    tmux
)
len=${#deps[*]}
package_list="/tmp/missing-packages.txt"
GREEN='\033[00;32m'
RED='\033[01;31m'
WHITE='\033[00;00m'
CYAN='\033[00;36m'

cmd_exists() { [ -x "$(command -v "$1")" ] && printf 0 || printf 1; }

check_deps() {
    printf "Checking to see if the following applications have been installed:\n"

    for (( i=0; i<=(($len -1)); i++)); do
        if [ $(cmd_exists ${deps[$i]}) -eq 0 ]; then
            printf "${GREEN}[✔]${WHITE} ${deps[$i]}\n"
        else
            printf "${RED}[✘] ${deps[$i]}${WHITE} is missing.\n"
            echo ${deps[$i]} >> $package_list
        fi
    done

    #--
    # Check to see if powerline-zsh & prezto are available & install or update
    # them as needed.
    #--     
    # github_grab function takes 3 arguments $localdir, $user, $repository 
    github_grab ${dotconfig}/carlcarl carlcarl powerline-zsh
    github_grab ${HOME}/.zprezto sorin-ionescu prezto.git

    # if package list exists, then install else symlink conf files.
    [ -f $package_list ] && install_deps || symlink_dotfiles
}

get_os() {
    os=`uname -s`

    if [ $os = 'Darwin' ]; then
        app_install="brew install"
    elif [ $os = 'FreeBSD' ]; then
        bsd_install="cd /usr/ports/devel/"
    elif [ $os = 'Darwin' ]; then
        app_install="brew install"
    elif [ $os = 'Linux' ]; then
        if [ $(cmd_exists apt-get) ]; then 
            app_install="sudo apt-get install"
        elif [ $(cmd_exists yum) ]; then 
            app_install="sudo yum install"
        elif [ $(cmd_exists up2date) ]; then 
            app_install="sudo up2date -i"
        else
            printf "${RED}[✘] ${WHITE}No package manager found for this Linux system!\n"
            exit 2
        fi
    else
        printf "${RED}[✘] ${WHITE}Unable to determine the operating system.\n"
        exit 2
    fi
}

github_grab() {
    localdir=$1
    user=$2
    repository=$3

    if [ ! -d ${localdir} ]; then
        printf "Cloning: https://github.com/${CYAN}${user}${WHITE}/${CYAN}${repository}${WHITE} to ${CYAN}${localdir}${WHITE}\n"
        git clone https://github.com/${user}/${repository} ${localdir}
    else
        printf "Updating: ${CYAN}${repository}${WHITE} in ${CYAN}${localdir}${WHITE}\n"
        cd ${localdir} && git pull
    fi

    if [ $repository = 'prezto.git' ]; then
        cd ${HOME}/.zprezto
        echo "Updating: ${CYAN}${repository}${WHITE} with ${CYAN}git pull && git submodule update --init --recursive${WHITE}"
        git pull && git submodule update --init --recursive
    fi

    if [ $repository = 'powerline-zsh' ]; then
        # create symlink for powerline-zsh
        if [ ! -f ${HOME}/.powerline-zsh.py ]; then
            ln -s ${dotconfig}/carlcarl/powerline-zsh.py ${HOME}/.powerline-zsh.py
        fi
    fi
}

install_deps() {
    printf "${CYAN}Attempting to install missing packages.${WHITE}\n"
    for package in `(cat ${package_list})`; do
        if [ $os != "FreeBSD" ]; then
            $app_install $package
        else
            $bsd_install $package && make && sudo make install
        fi
    done

    # delete /tmp/missing-packages.txt when done
    rm $package_list

    symlink_dotfiles
}

mkdr() {
    if [ ! -d $directory ]; then 
        mkdir -p $directory >/dev/null 2>&1 && \
            printf "${WHITE}Directory: ${CYAN}${directory} ${WHITE}created.\n" || \
            printf "${RED}Error: ${WHITE}Failed to create ${RED}${directory} ${WHITE}directory.\n"
    fi
}

vim_setup() {
    for directory in ${dir[@]}; do
        mkdr $directory
    done

    github_grab ${HOME}/.vim/bundle/Vundle.vim gmarik vundle.git

    printf "${WHITE}Installing vim plugins: ${CYAN} vim +PluginInstall +qall${WHITE}\n"
    sleep 1
    vim +PluginInstall +qall
}

symlink_dotfiles() {
    for file in `(find $dotdir -mindepth 2 -maxdepth 2 -type f -not -path '\.*' | grep -vE '(img|irssi|\.git)')`; do
        # softlink variable stores the absolute path for the symlink
        softlink=${HOME}/.`(echo $file | awk -F/ '{print $7}')`

        if [ ! -f ${softlink} ]; then
            ln -s ${file} ${softlink}
        fi
    done

    vim_setup
}

get_os
check_deps

# check to make sure ~/.conf directory exists
[ -d ${dotconfig} ] && echo "Using: ${CYAN}${dotconfig}${WHITE}" || mkdr directory=${dotconfig}

# clone or pull project from git
github_grab $dotconfig/dotfiles mclellac dotfiles
