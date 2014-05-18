#!/bin/bash
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
errquit()    { msgwarn $err; exit 1; }
msgsuccess() { msginfo $msg; }
msginfo()    { message=${@:-"${white}Error: No message passed"}; printf "${green}${message}${white}\n"; }
msgwarn()    { message=${@:-"${white}Error: No message passed"}; printf "${red}${message}${white}\n";   }


cmd_exists() {
    [ -x "$(command -v "$1")" ] \
        && printf 0 \
        || printf 1
}

main() {
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
        install_deps
    else
        vim_setup
    fi
}

install_deps() {
    os=`uname -s`

    printf "${cyan}Attempting to install missing packages.${white}\n"
    for package in `(cat ${package_list})`; do
       if [ $os = 'Linux' ]; then
           if [ $(cmd_exists apt-get) ]; then 
               sudo apt-get install $package
           elif [ $(cmd_exists yum) ]; then 
               sudo yum install $package
           elif [ $(cmd_exists up2date) ]; then 
               sudo up2date -i $package
           else
               echo 'No package manager found!'
               exit 2
           fi
       elif [ $os = 'FreeBSD' ]; then
           cd /usr/ports/devel/$package && make && sudo make install
       elif [ $os = 'Darwin' ]; then
           brew install $package
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

main