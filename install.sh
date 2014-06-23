#!/bin/bash
version="0.9"
declare -a dir=(
    ${HOME}/.vim
    ${HOME}/.vim/bundle
    ${HOME}/.vim/autoload
    ${HOME}/.vim/colors
    ${HOME}/.vim/backup
)
declare -a deps=(vim hg)
package_list="/tmp/missing-packages.txt"
# colours
green='\033[00;32m'
red='\033[01;31m'
white='\033[00;00m'
cyan='\033[1;36m'

cmd_exists() { [ -x "$(command -v "$1")" ] && printf 0 || printf 1; }

usage() {
cat << EOF
Usage: ${0##*/}     [-h] 
                    [-v] 
                    [-i] <option> 

Valid <option> for install: [vim|tmux|zsh|iTerm2]
Example: 
  To install the dotfiles for just vim type:
    
    ${0##*/} -i vim  

No options will make an assumption that you want to setup everything
in dotfiles.

  Options
  =======
  -i <option>      * Install the files for vim, tmux, zsh or iTerm2.
  -h               * Show this message.
  -v               * Print version.
EOF
}


mkdr() {
    if [ ! -d $directory ]; then 
        mkdir -p $directory >/dev/null 2>&1 && \
            printf "${green}Directory: ${cyan}${directory} ${white}created.\n" || \
            printf "${red}Error: ${white}Failed to create ${red}${directory} ${white}directory.\n"
    fi
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
        mv ${HOME}/.vim ${HOME}/.vim.`(date +%H%M-%d%m%y)` && mv ${HOME}/.vimrc ${HOME}/.vim.old
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

    # delete /tmp/missing-packages.txt when done.
    rm $package_list    
    vim_setup
}

copy_files() {
 echo 'copy_files()'
}

tmux_setup() {
    cp tmux/tmux.conf ${HOME}/.tmux.conf
}

zsh_setup() {
    for file in `(ls ./zsh)`; do cp $file ~/.${file}; done;
}

vim_setup() {
    for directory in ${dir[@]}; do
        mkdr $directory
    done

    if [ -d ${HOME}/.vim/bundle ] && [ ! -d ${HOME}/.vim/bundle/vim-go ]; then
        printf "${green}GitHub: ${cyan}fatih/vim-go.git  ${white}to ${cyan}${HOME}/.vim/bundle/vim-go. "
        git clone https://github.com/fatih/vim-go.git ${HOME}/.vim/bundle/vim-go -q 
        printf "${green}[done]${white}\n"
    fi
    
    if [ -d ${HOME}/.vim/autoload ]; then
        printf "${green}GitHub: ${cyan}gmarik/vundle.git ${white}to ${cyan}${HOME}/.vim/bundle/vundle. "
        git clone https://github.com/gmarik/vundle.git ${HOME}/.vim/bundle/vundle -q 
        printf "${green}[done]${white}\n"
        sleep 1
    fi

    printf "${white}Installing plugins.\n"
    sleep 1
    cp vim/vimrc ${HOME}/.vimrc && vim +PluginInstall +qall
    printf "${cyan}vimrc ${white}has been moved to ${cyan}~/.vimrc.\n"
    printf "${green}Install complete.${white}\n"
}

main() {
    install_app=""

    while getopts "i:hv" options; do
        echo $options
        case "${options}" in
            h|\?)
                usage
                exit 0
                ;;
            v)
                printf "${version}\n"
                exit 0
                ;;
            i)
                install_app=${OPTARG}
                echo $OPTARG
                ((  install_app == "vim"   || \
                    install_app == "tmux"  || \
                    install_app == "zsh"   || \
                    install_app == "iTerm2" )) || usage
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ -z "${s}" ] || [ -z "${p}" ]; then
        usage
    fi

#    os_check
}
main
#os_check
