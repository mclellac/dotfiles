## mclellac dotfiles
My collection of dotfiles.

![shell](img/shell.png)

## Installation
  The install script is very much tailored for myself. However, you are free to use, and change it in whatever way your heart desires.

  It will not make any backups of your current configuration, and it doesn't allow any argument passing to install specific portions. It did previously, but I find this way has less drawbacks for me personally.

### About install.sh
  The installer will also check to see if the commands vim, git, and tmux are available and it will install the packages for those applications if they aren't.

  dotfiles installs itself into your $HOME/.config/dotfiles directory and symlinks the relevant files to your $HOME. It will also install:

  * https://github.com/carlcarl/powerline-zsh  into $HOME/.config/carlcarl
  * https://github.com/sorin-ionescu/prezto    into $HOME/.zprezto
  * https://github.com/gmarik/Vundle.vim       into $HOME/.vim/bundle/Vundle.vim

### How to install
You paste this into your terminal, press enter, and it should take care of the rest. If you find any bugs, please let me know so I can address them.

```bash

sh <(curl -s https://raw.githubusercontent.com/mclellac/dotfiles/master/install.sh -L)

```
