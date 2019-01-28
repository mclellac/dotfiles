#!/usr/bin/env bash
#--
# Install script for github.com/mclellac/dotfiles
# Usage:
#    bash <(curl -s https://raw.githubusercontent.com/mclellac/dotfiles/master/install.sh -L)
#--
dotcfg="${HOME}/.config"
dotdir="${dotcfg}/dotfiles"
pkg_list="/tmp/missing-pkgs.txt"
# Global colour variables
grey="$(tput bold ; tput setaf 0)"
red=$(tput setaf 1)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
yellow=$(tput setaf 11)
blue=$(tput setaf 68)
brown=$(tput setaf 130)
orange=$(tput setaf 172)
rst=$(tput sgr0)

declare -a DIRECTORIES=(
    ${HOME}/.vim
    ${HOME}/.vim/bundle
    ${HOME}/.vim/autoload
    ${HOME}/.vim/colors
    ${HOME}/.vim/backup
)

declare -a DEPS=(
    curl
    vim
    git
    tmux
    clang
    shellcheck
    ctags
    libtool
    pkg-config
    python3
)
LEN=${#DEPS[*]}

error_quit()    { message_error $err; exit 1; }
message_ok()    { message=${@:-"[✘]: No OK content"};     printf "${green}[✔] ${message}${rst}\n"; }
message_error() { message=${@:-"[✘]: No error content"};  printf "${red}[✘] ${message}${rst}\n";   }
cmd_exists()    { [ -x "$(command -v "$1")" ] && printf 0 || printf 1; }

check_deps() {
    msg_box "Checking to see if the following applications have been installed"

    for (( i=0; i<=(($LEN -1)); i++)); do
        if [ $(cmd_exists ${DEPS[$i]}) -eq 0 ]; then
            printf "${green}[✔]${rst} ${DEPS[$i]}\n"
        else
            printf "${red}[✘] ${DEPS[$i]}${rst} is missing.\n"
            echo ${DEPS[$i]} >> $pkg_list
        fi
    done

    # If pkg list exists; then install. Otherwise symlink files.
    [ -f $pkg_list ] && install_deps || symlink_dotfiles
}

pkg_mgr() {
    if [[ $OSTYPE == 'darwin'* ]]; then
        app_installer="brew install"
        [ ! -f ${HOME}/.zsh.osx ] && touch ${HOME}/.zsh.osx
    elif [[ $OSTYPE == 'freebsd'* ]]; then
        bsd_installer="cd /usr/ports/devel/"
        [ ! -f ${HOME}/.zsh.bsd ] && touch ${HOME}/.zsh.bsd
    elif [[ $OSTYPE == 'linux-gnu' ]]; then
        [ ! -f ${HOME}/.zsh.gnu ] && touch ${HOME}/.zsh.gnu
        elif [ $(cmd_exists pacman) ]; then
            app_installer="sudo pacman -Syuu"
        if [ $(cmd_exists apt-get) ]; then
            app_installer="sudo apt-get install"
        elif [ $(cmd_exists dnf) ]; then
            app_installer="sudo dnf install"
        elif [ $(cmd_exists yum) ]; then
            app_installer="sudo yum install"
        elif [ $(cmd_exists up2date) ]; then
            app_installer="sudo up2date -i"
        else
            printf "${red}[✘] ${white}No pkg manager found for this Linux system!\n"
            exit 2
        fi
    else
        printf "${red}[✘] ${white}Unable to determine the operating system.\n"
        exit 2
    fi
}

# github_grab function takes 3 arguments $local_dir, $user, $project
github_grab() {
    local_dir=$1
    user=$2
    project=$3

    msg_box "Github: $user/$project"

    if [ ! -d ${local_dir} ]; then
        printf "Cloning: https://github.com/${cyan}${user}${rst}/${cyan}${project}${rst} to ${cyan}${local_dir}${rst}\n"
        git clone --recursive https://github.com/${user}/${project} ${local_dir}
    else
        printf "Updating: ${cyan}${project}${rst} in ${cyan}${local_dir}${rst}\n"
        cd ${local_dir} && git pull
    fi
}

install_deps() {
    msg_box "Attempting to install missing pkgs."
    for pkg in `(cat ${pkg_list})`; do
        if [[ $OSTYPE != "freebsd"* ]]; then
            $app_installer $pkg
        else
            $bsd_installer $pkg && make && sudo make install
        fi
    done

    # Delete /tmp/missing-pkgs.txt when done
    rm $pkg_list

    symlink_dotfiles
}

make_dir() {
    local directories="$*"

    if [ ! -d ${directories} ]; then
        mkdir -p ${directories} >/dev/null 2>&1 && \
            printf "${rst}DIRECTORIES: ${cyan}${directories} ${rst}created.\n" || \
            printf "${red}Error: ${rst}Failed to create ${red}${directories} ${rst}directories.\n"
    fi
}

msg_box() {
    local term_width=80  # This should be dynamic with: term_width=`stty size | cut -d ' ' -f 2`
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
    printf '%s┌' "${orange}" && printf '%.0s─' {0..79} && printf '┐\n' && printf '│%79s │\n'

    for line in "${str[@]}"; do
        rpad=$((80 - $pad - $msg_width)) # make sure to close with width 80
        printf "│%$pad.${pad}s" && printf '%s%*s' "$yellow" "-$msg_width" "$line" "${orange}" && printf "%$rpad.${rpad}s│\n"
    done

    printf '│%79s │\n' && printf  '└' && printf '%.0s─' {0..79}  && printf '┘\n%s' ${rst}
}

vim_setup() {
    for dir in ${DIRECTORIES[@]}; do
        make_dir $dir
    done

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    printf "${rst}Installing vim plugins: ${cyan} vim +PlugInstall +qall${rst}\n"
    sleep 1
    vim +PlugInstall +qall
}

symlink_dotfiles() {
    msg_box "Symlinking files to ${HOME}"

    for file in `(find $dotdir -mindepth 2 -maxdepth 2 -type f -not -path '\(.*)' | grep -vE '(iterm2|jhbuild|i3|img|irssi|git|weechat|zsh)')`; do
        # soft_ln variable stores the absolute path for the symlink
        soft_ln=${HOME}/.`(echo ${file} | awk -F/ '{print $7}')`

        if [ ! -f ${soft_ln} ]; then
            ln -s ${file} ${soft_ln}
        else
            rm ${soft_ln} && ln -s ${file} ${soft_ln}
        fi
    done

    # Copy git config files into $HOME, as we don't want them symlinked and mistakenly git pushed
    for file in `(ls ${dotdir}/git)`; do
        cp ${dotdir}/git/$file ${HOME}/.${file}
    done

    if [[ $OSTYPE == 'linux-gnu' ]]; then
        if [ -d ${HOME}/.i3 ]; then
            mv ${HOME}/.i3 ${HOME}/.i3.old && make_dir ${HOME}/.i3
        else
            make_dir ${HOME}/.i3
        fi

        ln -s ${dotdir}/i3/config ${HOME}/.i3/config
        ln -s ${dotdir}/i3/i3blocks.conf ${HOME}/.i3/i3blocks.conf
        cp -R ${dotdir}/i3/scripts ${HOME}/.i3/scripts
    fi

    # Only symlink zshrc to ~. Keep the rest of the zsh config
    # files in ~/.config/dotfiles/zsh and source them from there.
    ln -s ${dotdir}/zsh/zshrc ${HOME}/.zshrc

    # Is zplug installed? Install if it isn't.
    if [ ! -d ${HOME}/.zplug ]; then
        msg_box "Installing zplug"
        curl -sL --proto-redir -all,https \
            https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
    fi

    vim_setup
}

# Check to make sure ~/.conf DIRECTORIES exists
if [[ -d "${dotcfg}" ]]; then
   msg_box "Using: ${dotcfg}"
else
   make_dir "${dotcfg}"

# Check for ~/.zprivate file, create default if doesn't exist.
[ ! -f "${HOME}"/.zprivate ] && printf "# private variables\nexport WORK_DOMAIN=\"\"\nexport email=\"\"\nexport work_email=\"\"\n" >> .zprivate

# Clone or pull project from git
github_grab $dotcfg/dotfiles mclellac dotfiles

pkg_mgr
check_deps

# Install nerd-fonts for terminal emulator
msg_box "Installing nerd-fonts from:" \
        "https://github.com/ryanoasis/nerd-fonts"
github_grab ${dotcfg}/nerd-fonts ryanoasis nerd-fonts && sh ${dotcfg}/nerd-fonts/install.sh

msg_box "Installation complete."
printf "** Set your name and email in: ${cyan}${HOME}/.gitconfig${rst} **\n"

