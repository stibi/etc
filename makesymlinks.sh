#!/bin/bash
############################
# makesymlinks.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=`pwd`                    # dotfiles directory
olddir=`pwd`/dotfiles_old    # old dotfiles backup directory

if [ ! -d "$olddir" ]; then
    echo "Creating $olddir for backup of any existing dotfiles..."
    mkdir `pwd`/dotfiles_old;
    echo "...done"
fi

files="bashrc"    # list of files/folders to symlink in homedir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do
    if [ -f ~/.$file ]; then
	if [ ! -L ~/.$file ]; then
	    echo "Moving existing dotfile .$file from ~ to $olddir"
	    mv ~/.$file $olddir/$file;
	else
	    rm ~/.$file;
	fi
    fi
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done
