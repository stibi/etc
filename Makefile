# Makefile: Deploys links in all the right places.
# Inspired by: P.C. Shyamshankar <sykora@lucentbeing.com>,
# https://github.com/sykora/etc

# TODO mohl bych se zbavit tech rm a pouzit ln -sf, force prebije existujici soubor

all: git zsh st vim

git:
	rm ~/.gitconfig
	ln -s `pwd`/git/gitconfig ~/.gitconfig

zsh:
	rm ~/.zshrc ~/.oh-my-zsh/themes/stibi.zsh-theme
	ln -s `pwd`/zsh/themes/stibi.zsh-theme ~/.oh-my-zsh/themes/stibi.zsh-theme
	ln -s `pwd`/zsh/zshrc ~/.zshrc

st:
	# Same sublime-keymap config for Linux and OSX
	# TODO: fix this, ST2 on Arch is using OSX config file
	rm ~/.config/sublime-text-2/Packages/User/Default\ \(Linux\).sublime-keymap
	rm ~/.config/sublime-text-2/Packages/User/Default\ \(OSX\).sublime-keymap
	rm ~/.config/sublime-text-2/Packages/User/Preferences.sublime-settings
	ln -s `pwd`/sublimetext2/Default\ \(Linux\).sublime-keymap ~/.config/sublime-text-2/Packages/User/Default\ \(Linux\).sublime-keymap
	ln -s ~/.config/sublime-text-2/Packages/User/Default\ \(Linux\).sublime-keymap ~/.config/sublime-text-2/Packages/User/Default\ \(OSX\).sublime-keymap
	ln -s `pwd`/sublimetext2/Preferences.sublime-settings ~/.config/sublime-text-2/Packages/User/Preferences.sublime-settings

vim:
	rm ~/.vimrc
	ln -s `pwd`/vim/vimrc ~/.vimrc
