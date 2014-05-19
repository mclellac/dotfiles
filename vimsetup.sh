#!/bin/bash
appname=`basename "$0"`
declare -a a=(
    vim
    hg
)
len=${#a[*]}
package_list="/tmp/missing-packages.txt"
# colours
green='\033[00;32m'
red='\033[01;31m'
white='\033[00;00m'
cyan='\033[1;36m'

cmd_exists() { [ -x "$(command -v "$1")" ] && printf 0 || printf 1; }

print_help() {
    cat << EOF
Usage: $appname 

    TODO

EOF
}

os_check() {
    os=`uname -s`

    if [ $os = 'Linux' ]; then
        if [ $(cmd_exists apt-get) ]; then 
            app_install="sudo apt-get install"
        elif [ $(cmd_exists yum) ]; then 
            app_install="sudo yum install"
        elif [ $(cmd_exists up2date) ]; then 
            app_install="sudo up2date -i"
        else
            printf "${red}[✘] ${white}No package manager found for this Linux system!\n"
            exit 2
        fi
    elif [ $os = 'FreeBSD' ]; then
        bsd_install="cd /usr/ports/devel/"
    elif [ $os = 'Darwin' ]; then
        app_install="brew install"
    else
        printf "${red}[✘] ${white}Unable to determine the operating system.\n"
        exit 2
    fi

    dependency_check
}

dependency_check() {
    if [ -d ${HOME}/.vim/bundle/ ]; then
        printf "${red}Moving old vim configuration files into ${HOME}/.vim.old${white}\n"
        mv ${HOME}/.vim ${HOME}/.vim.old && mv ${HOME}/.vimrc ${HOME}/.vim.old
    fi

    printf "Checking to see if the following applications have been installed:\n"
    for (( i=0; i<=$(( $len -1 )); i++ )); do
        if [ $(cmd_exists ${a[$i]}) -eq 0 ]; then
            printf "${green}[✔]${white} ${a[$i]}\n"
        else
            printf "${red}[✘] ${a[$i]}${white} is missing.\n"
            echo ${a[$i]} >> $package_list
        fi
    done

    if [ -f $package_list ]; then
        install_dependencies
    else
        vim_setup
    fi
}

install_dependencies() {
    printf "${cyan}Attempting to install missing packages.${white}\n"
    for package in `(cat ${package_list})`; do
        if [ $os != "FreeBSD" ];
            app_install $package
        else
            bsd_install $package && make && sudo make install
        fi
    done

    # delete /tmp/missing-packages.txt when done.
    rm $package_list    
    vim_setup
}

vim_setup() {
    if [ ! -d ${HOME}/.vim/autoload ] || [ ! -d ${HOME}/.vim/bundle ]; then
        mkdir -p ${HOME}/.vim/autoload ${HOME}/.vim/bundle
    fi
    
    if [ -d ${HOME}/.vim/bundle ] && [ ! -d ${HOME}/.vim/bundle/vim-go ]; then
        printf "github.com: ${white}Cloning ${cyan}fatih/vim-go.git  ${white}to ${cyan}~/.vim/bundle/vim-go. "
        git clone https://github.com/fatih/vim-go.git ${HOME}/.vim/bundle/vim-go -q 
        printf "${green}[done]${white}\n"
    fi
    
    if [ -d ${HOME}/.vim/autoload ]; then
        printf "github.com: ${white}Cloning ${cyan}gmarik/vundle.git ${white}to ${cyan}~/.vim/bundle/vundle. "
        git clone https://github.com/gmarik/vundle.git ${HOME}/.vim/bundle/vundle -q 
        printf "${green}[done]${white}\n"
        sleep 1
    fi

    printf "${white}Installing plugins.\n"
    sleep 1
    cp vimrc ${HOME}/.vimrc && vim +PluginInstall +qall
    printf "${cyan}vimrc ${white}has been moved to ${cyan}~/.vimrc.\n"
    printf "${green}Install complete.${white}\n"
}

os_check
