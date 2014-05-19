#!/bin/sh
workdir="${HOME}/Projects"
dotfiles="${workdir}/dotfiles"
pl="git+git://github.com/Lokaltog/powerline"
plsh="https://github.com/milkbikis/powerline-shell"
plshdir="/usr/lib/powerline"

if [ ! -d $workdir ]; then
    mkdir $workdir
fi

if [ ! -d $dotfiles ]; then
    cd $workdir && git clone https://github.com/mclellac/dotfiles 
fi

if [ -f ${dotfiles}/README.md ]; then
    rm ${dotfiles}/README.md
fi


#cd $dotfiles
#for file in `(ls $dotfiles)`;
#do 
#    mv $file ${HOME}/.$file; 
#done

# install powerline
cd $workdir && pip install --user $pl

git clone $plsh && sudo mv powerline-shell $plshdir

if [ -d $plshdir ]; then
    sudo chown -R mclellac $plshdir && sudo chmod 744 $plshdir
    cd $plshdir && ./install.py
fi

rm -rf $dotfiles ${workdir}/Projects/powerline-shell