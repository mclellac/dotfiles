#!/usr/bin/env bash
#--
# Install script for github.com/mclellac dotfiles
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
    tmux
)
len=${#deps[*]}
package_list="/tmp/missing-packages.txt"
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
    github_grab ${dotconfig}/carlcarl carlcarl powerline-zsh
    github_grab ${HOME}/.zprezto sorin-ionescu prezto.git

    # Install powerline fonts.
    github_grab ${dotconfig}/powerline-fonts powerline fonts && sh ${dotconfig}/powerline-fonts/install.sh 

    # if package list exists, then install else symlink conf files.
    [ -f $package_list ] && install_deps || symlink_dotfiles
}

get_os() {
    os=`uname -s`

    if [ $os = 'Darwin' ]; then
        app_install="brew install"
        [ ! -f ${HOME}/.zsh.osx ] && touch ${HOME}/.zsh.osx
    elif [ $os = 'FreeBSD' ]; then
        bsd_install="cd /usr/ports/devel/"
        [ ! -f ${HOME}/.zsh.bsd ] && touch ${HOME}/.zsh.bsd
    elif [ $os = 'Linux' ]; then
        [ ! -f ${HOME}/.zsh.gnu ] && touch ${HOME}/.zsh.gnu
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

# github_grab function takes 3 arguments $localdir, $user, $repository 
github_grab() {
    localdir=$1
    user=$2
    repository=$3

    if [ ! -d ${localdir} ]; then
        separator
        printf "Cloning: https://github.com/${CYAN}${user}${WHITE}/${CYAN}${repository}${WHITE} to ${CYAN}${localdir}${WHITE}\n"
        git clone https://github.com/${user}/${repository} ${localdir}
    else
        separator
        printf "Updating: ${CYAN}${repository}${WHITE} in ${CYAN}${localdir}${WHITE}\n"
        cd ${localdir} && git pull
    fi

    # if zpresto has been installed, then update the submodules.
    if [ $repository = 'prezto.git' ]; then
        separator
        cd ${HOME}/.zprezto
        echo "Updating: ${CYAN}${repository}${WHITE} with ${CYAN}git pull && git submodule update --init --recursive${WHITE}"
        git pull && git submodule update --init --recursive
    fi
}

install_deps() {
    separator
    
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

make_dir() {
    if [ ! -d $directory ]; then 
        mkdir -p $directory >/dev/null 2>&1 && \
            printf "${WHITE}Directory: ${CYAN}${directory} ${WHITE}created.\n" || \
            printf "${RED}Error: ${WHITE}Failed to create ${RED}${directory} ${WHITE}directory.\n"
    fi
}

vim_setup() {
    for directory in ${dir[@]}; do
        make_dir $directory
    done

    github_grab ${HOME}/.vim/bundle/Vundle.vim gmarik vundle.git

    printf "${WHITE}Installing vim plugins: ${CYAN} vim +PluginInstall +qall${WHITE}\n"
    sleep 1
    vim +PluginInstall +qall

    separator
}

symlink_dotfiles() {
    # softlink variable stores the absolute path for the symlink

    for file in `(find $dotdir -mindepth 2 -maxdepth 2 -type f -not -path '\(.*)' | grep -vE '(img|irssi|git)')`; do
        softlink=${HOME}/.`(echo ${file} | awk -F/ '{print $7}')`

        if [ ! -f ${softlink} ]; then
            ln -s ${file} ${softlink}
        else 
            rm ${softlink} && ln -s ${file} ${softlink}
        fi
    done

    # Copy git config files into $HOME, as we don't want them symlinked and mistakenly git pushed
    for file in `( ls ${dotdir}/git)`; do
        cp ${dotdir}/git/$file ${HOME}/.${file}
    done 

    vim_setup
}

separator

# check to make sure ~/.conf directory exists
[ -d ${dotconfig} ] && echo "Using: ${CYAN}${dotconfig}${WHITE}" || make_dir directory=${dotconfig}

# check for ~/.zprivate file, create default if doesn't exist.
[ ! -f ${HOME}/.zprivate ] && printf "#-- private variables --\nexport email=\"\"\nexport work_email=\"\"\n" >> .zprivate

# clone or pull project from git
github_grab $dotconfig/dotfiles mclellac dotfiles

get_os
check_deps
