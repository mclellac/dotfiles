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
red=$(tput setaf 1)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
yellow=$(tput setaf 11)
orange=$(tput setaf 172)
rst=$(tput sgr0)

declare -a DIRECTORIES=(
    "${HOME}"/.vim
    "${HOME}"/.vim/bundle
    "${HOME}"/.vim/autoload
    "${HOME}"/.vim/colors
    "${HOME}"/.vim/backup
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

# error_quit()    { message_error $err; exit 1; }
# message_ok()    { message=${@:-"[✘]: No OK content"};     printf "${green}[✔] ${message}${rst}\n"; }
# message_error() { message=${@:-"[✘]: No error content"};  printf "${red}[✘] ${message}${rst}\n";   }
cmd_exists()    { [ -x "$(command -v "$1")" ] && printf 0 || printf 1; }

check_deps() {
    msg_box "Checking to see if the following applications have been installed."

    for (( i=0; i<=((LEN -1)); i++ )); do
        if [ "$(cmd_exists "${DEPS[$i]}")" -eq 0 ]; then
            printf "%s[✔]%s %s\n" "${green}" "${rst}" "${DEPS[$i]}"
        else
            printf "%s[✘] %s%s is missing.\n" "${red}" "${DEPS[$i]}" "${rst}"
            echo "${DEPS[$i]}" >> "${pkg_list}"
        fi
    done

    # If pkg_list exists; then install packages in list. Otherwise symlink files.
    if [ -f "${pkg_list}" ]; then
        install_deps
    else
        symlink_dotfiles
    fi
}

pkg_mgr() {
    if [[ $OSTYPE == 'darwin'* ]]; then
        app_regex='(weechat|mutt|polybar|i3|img|git|zsh|doom.d)'
        app_installer="brew install"
        [ ! -f "${HOME}"/.zsh.osx ] && touch "${HOME}"/.zsh.osx
    elif [[ $OSTYPE == 'freebsd'* ]]; then
        app_regex='(mutt|polybar|i3|img|git|zsh)'
        bsd_installer="cd /usr/ports/devel/"
        [ ! -f "${HOME}"/.zsh.bsd ] && touch "${HOME}"/.zsh.bsd
    elif [[ $OSTYPE == 'linux-gnu' ]]; then
        app_regex='(mutt|polybar|i3|img|git|zsh|doom.d)'
        [ ! -f "${HOME}"/.zsh.gnu ] && touch "${HOME}"/.zsh.gnu
        elif [ "$(cmd_exists pacman)" ]; then
            app_installer="sudo pacman -Syuu"
        if [ "$(cmd_exists apt-get)" ]; then
            app_installer="sudo apt-get install"
        elif [ "$(cmd_exists dnf)" ]; then
            app_installer="sudo dnf install"
        elif [ "$(cmd_exists yum)" ]; then
            app_installer="sudo yum install"
        elif [ "$(cmd_exists up2date)" ]; then
            app_installer="sudo up2date -i"
        else
            printf "%s[✘] %sNo pkg manager found for this Linux system!\n" "${red}" "${white}"
            exit 2
        fi
    else
        printf "%s[✘] %sUnable to determine the operating system.\n" "${red}" "${white}"
        exit 2
    fi
}

# github_grab function takes 3 arguments $local_dir, $user, $project
github_grab() {
    local_dir=$1
    user=$2
    project=$3

    msg_box "Github: $user/$project."

    if [ ! -d "${local_dir}" ]; then
        printf "Cloning: https://github.com/%s%s%s/%s%s%s to %s%s%s\n" "${cyan}" "${user}" "${rst}" "${cyan}" "${project}" "${rst}" "${cyan}" "${local_dir}" "${rst}"
        git clone --recursive https://github.com/"${user}"/"${project}" "${local_dir}"
    else
        printf "Updating: %s%s%s in %s%s%s\n" "${cyan}" "${project}" "${rst}" "${cyan}" "${local_dir}" "${rst}"
        cd "${local_dir}" && git pull
    fi
}

install_deps() {
    msg_box "Attempting to install missing pkgs."

    while IFS= read -r pkg; do
        if [[ $OSTYPE != "freebsd"* ]]; then
            $app_installer "${pkg}"
        else
            $bsd_installer "${pkg}" && make && sudo make install
        fi
    done < "${pkg_list}"

    # Delete /tmp/missing-pkgs.txt when done
    rm "${pkg_list}"

    symlink_dotfiles
}

make_dir() {
    local directories="$*"

    if [ ! -d "${directories}" ]; then
        mkdir -p "${directories}" >/dev/null 2>&1 && \
            printf "%sDIRECTORIES: %s%s%s created.\n" "${rst}" "${cyan}" "${directories}" "${rst}" || \
            printf "%sError: %sFailed to create %s%s%s directories.\n" "${red}" "${rst}" "${red}" "${directories}" "${rst}"
    fi
}

msg_box() {
    local term_width=80  # This should be dynamic with: term_width=`stty size | cut -d ' ' -f 2`
    local str=("$@") msg_width

    printf '\n'

    for line in "${str[@]}"; do
        ((msg_width<${#line})) && { msg_width="${#line}"; }

        if [ "${msg_width}" -gt "${term_width}" ]; then
            error_quit "error: msg_box() >> \$msg_width exceeds \${term_width}. Split message into multiple lines or decrease the number of characters.\n"
        fi

        x=$(("${term_width}" - "${msg_width}"))
        pad=$(("${x}" / 2))
    done

    # draw box
    printf '%s┌' "${orange}" &&  printf '%.0s─' {0..79} && printf '┐\n' && printf '│%79s │\n' " "

    for line in "${str[@]}"; do
        rpad=$((80 - "${pad}" - "${msg_width}")) # make sure to close with width 80
        printf "│%${pad}.${pad}s"
        printf '%s%*s%s' "$yellow" "-$msg_width" "$line" "${orange}"
        printf "%${rpad}.${rpad}s│\n"
    done

    printf '│%79s │\n' " " && printf  '└' && printf '%.0s─' {0..79}  && printf '┘\n%s' "${rst}"
}

vim_setup() {
    msg_box "Setting up Vim."
    for dir in "${DIRECTORIES[@]}"; do
        make_dir "${dir}"
    done

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    printf "%sInstalling vim plugins: %svim +PlugInstall +qall%s\n" "${rst}" "${cyan}" "${rst}"
    sleep 1
    vim +PlugInstall +qall
}

symlink_dotfiles() {
    msg_box "Symlinking files to: ${HOME}."

    for file in $(find "${dotdir}" -mindepth 2 -maxdepth 2 -type f -not -path '\(.*)' | grep -vE "${app_regex}"); do
        # soft_ln variable stores the absolute path for the symlink
        softln="${HOME}"/.$(echo "${file}" | awk -F/ '{print $7}')

        if [ ! -f "${softln}" ]; then
            echo "${cyan}Symlinking${rst} ${file} ${cyan}->${rst} ${softln}"
            ln -s "${file}" "${softln}"
        else
            echo "${cyan}Symlinking${rst} ${file} ${cyan}->${rst} ${softln}"
            ln -sf "${file}" "${softln}"
        fi
    done

    # Copy git config files into $HOME, as we don't want them symlinked and mistakenly git pushed
    for file in git/*; do
        [[ -e "${file}" ]] || break  # handle the case of no files
        f=$(echo "${file}" | awk -F/ '{print $2}')
        echo "${cyan}Copying${rst} ${file} ${cyan}->${rst} ${HOME}/.${f}"
        cp -n "${file}" "${HOME}"/."${f}"
    done

    #if [[ $OSTYPE == 'linux-gnu' ]]; then
    #    if [ -d "${HOME}"/.i3 ]; then
    #        mv "${HOME}"/.i3 "${HOME}"/.i3.old && make_dir "${HOME}"/.i3
    #    else
    #        make_dir "${HOME}"/.i3
    #    fi

    #    ln -s "${dotdir}"/i3/config "${HOME}"/.i3/config
    #    ln -s "${dotdir}"/i3/i3blocks.conf "${HOME}"/.i3/i3blocks.conf
    #    cp -R "${dotdir}"/i3/scripts "${HOME}"/.i3/scripts
    #fi

    # Only symlink zshrc to the home directory. Keep the rest of the zsh config
    # files in ~/.config/dotfiles/zsh and source them from there.
    ln -sf "${dotdir}"/zsh/zshrc "${HOME}"/.zshrc

    # Is zplug installed? Install if it isn't.
    #if [ ! -d "${HOME}"/.zplug ]; then
    #    msg_box "Installing zplug."
    #    curl -sL --proto-redir -all,https \
    #        https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
    #fi

    vim_setup
}

# Check to make sure ~/.conf DIRECTORIES exists
if [[ -d "${dotcfg}" ]]; then
   msg_box "Using: ${dotcfg}."
else
   make_dir "${dotcfg}"
fi

# Check for ~/.zprivate file, create default if doesn't exist.
[ ! -f "${HOME}"/.zprivate ] && printf "# private variables\nexport WORK_DOMAIN=\"\"\nexport email=\"\"\nexport work_email=\"\"\n" >> .zprivate

# Clone or pull project from git
github_grab "${dotcfg}"/dotfiles mclellac dotfiles

pkg_mgr
check_deps

# Install nerd-fonts for terminal emulator
# msg_box "Installing nerd-fonts from:" \
#         "https://github.com/ryanoasis/nerd-fonts"
# github_grab "${dotcfg}"/nerd-fonts ryanoasis nerd-fonts && sh "${dotcfg}"/nerd-fonts/install.sh

msg_box "Installation complete."
printf "** Set your name and email in: %s%s/.gitconfig%s **\n" "${cyan}" "${HOME}" "${rst}"
