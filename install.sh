#!/usr/bin/env bash
#--
# install script for github.com/mclellac dotfiles
# Usage:
#    sh <(curl -s https://raw.githubusercontent.com/mclellac/dotfiles/master/install.sh -L)
#--
dotconf="${HOME}/.config"
dotdir="${dotconf}/dotfiles"
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
#-- text colour variables & output helper functions. --
green='\033[00;32m'
red='\033[01;31m'
white='\033[00;00m'

cmd_exists() { [ -x "$(command -v "$1")" ] && printf 0 || printf 1; }

zprezto() {
    if [ -d ${HOME}/.zprezto ]; then
        printf "${cyan}Updating Prezto${white}"
        cd ${HOME}/.zprezto
        git pull && git submodule update --init --recursive
    else
        printf "${green}Installing Prezto to: ${cyan}${HOME}/.zprezto${white}"
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    fi
    
    symlink
}

os_check() {
    os=`uname -s`

    if [ $os == 'Darwin' ]; then
        app_install="brew install"
        echo "${os} detected. Using ${app_install}"
    elif [ $os == 'FreeBSD' ]; then
        bsd_install="cd /usr/ports/devel/"
    elif [ $os == 'Darwin' ]; then
        app_install="brew install"
    elif [ $os == 'Linux' ]; then
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
    else
        printf "${red}[✘] ${white}Unable to determine the operating system.\n"
        exit 2
    fi

    dependency_check
}

mkdr() {
    if [ ! -d $directory ]; then 
        mkdir -p $directory >/dev/null 2>&1 && \
            printf "${green}Directory: ${cyan}${directory} ${white}created.\n" || \
            printf "${red}Error: ${white}Failed to create ${red}${directory} ${white}directory.\n"
    fi
}

dependency_check() {
    #-- TODO: check for following and install if not found.
    #   prezto, powerline, tmux powerline --

    #if [ -d ${HOME}/.vim/bundle/ ]; then
    #    printf "${red}Moving old vim configuration files into ${HOME}/.vim.`(date +%H%M-%d%m%y)`${white}\n"
    #    mkdir ${HOME}/.vim.`(date +%H%M-%d%m%y)` && 
    #    mv ${HOME}/.vim ${HOME}/.vim.`(date +%H%M-%d%m%y)` && mv ${HOME}/.vimrc ${HOME}/.vim.`(date +%H%M-%d%m%y)`
    #fi
    printf "Checking to see if the following applications have been installed:\n"

    for (( i=0; i<=(($len -1)); i++)); do
        if [ $(cmd_exists ${deps[$i]}) -eq 0 ]; then
            printf "${green}[✔]${white} ${deps[$i]}\n"
        else
            printf "${red}[✘] ${deps[$i]}${white} is missing.\n"
            echo ${deps[$i]} >> $package_list
        fi
    done

    #-- if package list exists, then install else symlink conf files. -- 
    [ -f $package_list ] && install_dependencies || symlink
}

install_dependencies() {
    printf "${cyan}Attempting to install missing packages.${white}\n"
    for package in `(cat ${package_list})`; do
        if [ $os != "FreeBSD" ]; then
            $app_install $package
        else
            $bsd_install $package && make && sudo make install
        fi
    done

    #-- delete /tmp/missing-packages.txt when done --
    rm $package_list    
    zprezto
}

vim_setup() {
    for directory in ${dir[@]}; do
        mkdr $directory
    done

    if [ ! -d ${HOME}/.vim/bundle/vim-go ]; then
        printf "${green}GitHub: ${cyan}fatih/vim-go.git  ${white}to ${cyan}${HOME}/.vim/bundle/vim-go. "
        git clone https://github.com/fatih/vim-go.git ${HOME}/.vim/bundle/vim-go -q 
        printf "${green}[done]${white}\n"
    fi
    
    if [ ! -d ${dotconf}/vim/bundle/vundle ]; then
        printf "${green}GitHub: ${cyan}gmarik/vundle.git ${white}to ${cyan}${HOME}/.vim/bundle/vundle. "
        git clone https://github.com/gmarik/Vundle.vim.git ${HOME}/.vim/bundle/Vundle.vim -q 
        printf "${green}[done]${white}\n"
        sleep 1
    fi

    printf "${white}Installing vim plugins.\n"
    sleep 1
    vim +PluginInstall +qall
}


symlink() {
    for file in `(find ${dotdir} -mindepth 2 -maxdepth 2 -type f -not -path '\.*' | grep -v irssi | grep -v .git)`; do
        #-- softlink variable stores the absolute path for the symlink --
        softlink=${HOME}/.`(echo $file | awk -F/ '{print $7}')`

        if [ ! -f ${softlink} ]; then
            ln -s ${file} ${softlink}
        fi
    done

    vim_setup
}

#-- check to make sure ~/.conf directory exists --
[ -d ${dotconf} ] && echo "using ${dotconf}" || mkdir ${dotconf}

#-- clone or pull project from git --
if [ ! -d $dotconf/dotfiles ]; then
    git clone https://github.com/mclellac/dotfiles/ ${dotdir} && cd ${dotdir}
elif [ -d $dotconf/dotfiles ]; then
    cd $dotconf/dotfiles && git pull  && cd ${dotdir}
fi

os_check