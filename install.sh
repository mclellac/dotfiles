#!/bin/bash
#--
# install script for github.com/mclellac dotfiles
# Usage:
#    sh <(curl -s https://raw.githubusercontent.com/mclellac/dotfiles/master/install.sh -L)
#--
dotconf="${HOME}/.config"
dotdir="${dotconf}/dotfiles"
declare -a dir=(
    ${HOME}/.config/vim
    ${HOME}/.config/vim/bundle
    ${HOME}/.config/vim/autoload
    ${HOME}/.config/vim/colors
    ${HOME}/.config/vim/backup
)
declare -a deps=(vim git hg)

# text colour variables & output helper functions.
green='\033[00;32m'
red='\033[01;31m'
white='\033[00;00m'
errquit()    { msgwarn $err; exit 1; }
msgsuccess() { msginfo $msg; }
msginfo()    { message=${@:-"${white}Error: No message passed"}; printf "${green}${message}${white}\n"; }
msgwarn()    { message=${@:-"${white}Error: No message passed"}; printf "${red}${message}${white}\n";   }

cmd_exists() { [ -x "$(command -v "$1")" ] && printf 0 || printf 1; }

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
        printf "${red}Moving old vim configuration files into ${HOME}/.vim.`(date +%H%M-%d%m%y)`${white}\n"
        mkdir ${HOME}/.vim.`(date +%H%M-%d%m%y)` && 
        mv ${HOME}/.vim ${HOME}/.vim.`(date +%H%M-%d%m%y)` && mv ${HOME}/.vimrc ${HOME}/.vim.`(date +%H%M-%d%m%y)`
    fi

    printf "Checking to see if the following applications have been installed:\n"
    for i in ${!deps[*]}; do
        if [ $(cmd_exists ${deps[$i]}) -eq 0 ]; then
            printf "${green}[✔]${white} ${deps[$i]}\n"
        else
            printf "${red}[✘] ${deps[$i]}${white} is missing.\n"
            echo ${deps[$i]} >> $package_list
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
        if [ $os != "FreeBSD" ]; then
            app_install $package
        else
            bsd_install $package && make && sudo make install
        fi
    done

    #-- delete /tmp/missing-packages.txt when done. --
    rm $package_list    
    vim_setup
}

symlink() {
    for file in `(find ${dotdir} -mindepth 2 -maxdepth 2 -type f -not -path '*/\.*')`; do 
        ln $file `(echo $file | awk -F/ '{print $4}')`
    done
}

#-- check to make sure ~/.conf directory exists --
[ -d ${dotconf} ] && echo "using ${dotconf}" || mkdir ${dotconf}

#-- clone or pull project from git --
if [ ! -d $dotconf/dotfiles ]; then
    git clone https://github.com/mclellac/dotfiles/ $dotconf && cd $dotconf
elif [ -d $dotconf/dotfiles ]; then
    cd $dotconf/dotfiles && git pull  && cd $dotconf
fi

os_check
symlink