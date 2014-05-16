#!/bin/bash
a=(
    vim
    hg
)
len=${#a[*]}
green='\033[00;32m'
red='\033[01;31m'
white='\033[00;00m'
errquit()    { msgwarn $err; exit 1; }
msgsuccess() { msginfo $msg; }
msginfo()    { message=${@:-"${white}Error: No message passed"}; printf "${green}${message}${white}\n"; }
msgwarn()    { message=${@:-"${white}Error: No message passed"}; printf "${red}${message}${white}\n";   }

pkgmgr() {
    # function to determine which package manager is being used on the host OS.
    [ -x "$(which $1)" ]
}

chkdeps() {
    echo "Checking to see if the following applications have been installed:"
    for (( i=0; i<=$(( $len -1 )); i++ )); do
        msg="[✔]${white} ${a[$i]}"
        command -v ${a[$i]} >/dev/null 2>&1 || {
            err="[✘] ${white}Please install ${red}${a[$i]}${white}. Attempting to install" >&2 errquit
        }
        msgsuccess $msg
    done
    vimsetup
}

chkos() {
    os=`uname`
    #TODO: Modify chkdeps to be able to handle installing missing deps
    ##################################################################
    if [ $os = 'Linux' ]; then
        if pkgmgr apt-get ; then 
            sudo apt-get install $app
        elif pkgmgr yum ; then 
            sudo yum install $app
        elif pkgmgr up2date ; then 
            sudo up2date -i $app
        else
            echo 'No package manager found!'
            exit 2
        fi
    elif [ $os = 'FreeBSD' ]; then
        cd /usr/ports/devel/$app && make && sudo make install
    elif [ $os = 'Darwin' ]; then
        brew install $app
    fi
}

vimsetup() {
    if [ ! -d ${HOME}/.vim/autoload ] || [ ! -d ${HOME}/.vim/bundle ]; then
        mkdir -p ${HOME}/.vim/autoload ${HOME}/.vim/bundle
    fi
    
    if [ -d ${HOME}/.vim/bundle ] && [ ! -d ${HOME}/.vim/bundle/vim-go ]; then
        git clone https://github.com/fatih/vim-go.git ${HOME}/.vim/bundle/vim-go
    fi
    
    if [ -d ${HOME}/.vim/autoload ]; then
        git clone https://github.com/gmarik/vundle.git ${HOME}/.vim/bundle/vundle
    fi
}

chkdeps
