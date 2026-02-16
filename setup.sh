#!/usr/bin/env bash

# arg number check
if [ $# -lt 1 ]
then
    echo "Usage: $0 /absolute/path/to/conf/git [--force]"
    exit 1
fi

# absolute directory path check
case $1 in
    /*)
        if [ ! -d "$1" ]
        then
            echo "$1 is not a directory"
            exit 1
        fi
        ;;
    *)
        echo "$1 is not an absolute path"
        exit 1
        ;;
esac

rmflags="-ivr"
if [ "$2" = "--force" ]
then
    rmflags="-fvr"
fi

# dir
echo "Link: ~/.paps -> $1"
rm $rmflags ~/.paps
ln -sT "$1" ~/.paps

# ssh
mkdir -v -p ~/.ssh

echo "Link: ~/.ssh/config -> ~/.paps/ssh/config"
rm $rmflags ~/.ssh/config
ln -sT ~/.paps/ssh/config ~/.ssh/config
chmod -v og-rwx ~/.ssh/config

echo "curl: https://github.com/paps.keys -> ~/.ssh/authorized_keys"
rm $rmflags ~/.ssh/authorized_keys
curl --silent 'https://github.com/paps.keys' -o ~/.ssh/authorized_keys
chmod -v og-rwx ~/.ssh/authorized_keys

# X11
echo "Link: ~/.Xresources -> ~/.paps/x/Xresources"
rm $rmflags ~/.Xresources
ln -sT ~/.paps/x/Xresources ~/.Xresources

echo "Link: ~/.xsession -> ~/.paps/x/xsession"
rm $rmflags ~/.xsession
ln -sT ~/.paps/x/xsession ~/.xsession

echo "Link: ~/.xinitrc -> ~/.paps/x/xsession"
rm $rmflags ~/.xinitrc
ln -sT ~/.paps/x/xsession ~/.xinitrc

echo "Link: ~/.Xmodmap -> ~/.paps/x/Xmodmap"
rm $rmflags ~/.Xmodmap
ln -sT ~/.paps/x/Xmodmap ~/.Xmodmap

# gtk 3
mkdir -v -p ~/.config/gtk-3.0
echo "Link: ~/.config/gtk-3.0/settings.ini -> ~/.paps/gtk/settings3.ini"
rm $rmflags ~/.config/gtk-3.0/settings.ini
ln -sT ~/.paps/gtk/settings3.ini ~/.config/gtk-3.0/settings.ini

# gtk 2
mkdir -v -p ~/.config/gtk-2.0
echo "Link: ~/.config/gtk-2.0/settings.ini -> ~/.paps/gtk/settings2.ini"
rm $rmflags ~/.config/gtk-2.0/settings.ini
ln -sT ~/.paps/gtk/settings2.ini ~/.config/gtk-2.0/settings.ini

echo "Link: ~/.gtkrc-2.0 -> ~/.paps/gtk/settings2.ini"
rm $rmflags ~/.gtkrc-2.0
ln -sT ~/.paps/gtk/settings2.ini ~/.gtkrc-2.0

# qt
mkdir -v -p ~/.qt

echo "Link: ~/.qt/qtrc -> ~/.paps/qt/qtrc"
rm $rmflags ~/.qt/qtrc
ln -sT ~/.paps/qt/qtrc ~/.qt/qtrc

echo "Link: ~/.config/Trolltech.conf -> ~/.paps/qt/Trolltech.conf"
rm $rmflags ~/.config/Trolltech.conf
ln -sT ~/.paps/qt/Trolltech.conf ~/.config/Trolltech.conf

echo "Link: ~/.config/QtProject.conf -> ~/.paps/qt/QtProject.conf"
rm $rmflags ~/.config/QtProject.conf
ln -sT ~/.paps/qt/QtProject.conf ~/.config/QtProject.conf

# icons
echo "Link: ~/.icons -> ~/.paps/icons"
rm $rmflags ~/.icons
ln -sT ~/.paps/icons ~/.icons

# fonts
echo "Link: ~/.fonts.conf -> ~/.paps/fonts/fonts.conf"
rm $rmflags ~/.fonts.conf
ln -sT ~/.paps/fonts/fonts.conf ~/.fonts.conf

echo "Link: ~/.fonts -> ~/.paps/fonts"
rm $rmflags ~/.fonts
ln -sT ~/.paps/fonts ~/.fonts

# openbox
mkdir -v -p ~/.config/openbox

echo "Link: ~/.config/openbox/menu.xml -> ~/.paps/openbox/menu.xml"
rm $rmflags ~/.config/openbox/menu.xml
ln -sT ~/.paps/openbox/menu.xml ~/.config/openbox/menu.xml

echo "Link: ~/.config/openbox/rc.xml -> ~/.paps/openbox/rc.xml"
rm $rmflags ~/.config/openbox/rc.xml
ln -sT ~/.paps/openbox/rc.xml ~/.config/openbox/rc.xml

echo "Link: ~/.config/openbox/autostart.sh -> ~/.paps/openbox/autostart.sh"
rm $rmflags ~/.config/openbox/autostart.sh
ln -sT ~/.paps/openbox/autostart.sh ~/.config/openbox/autostart.sh

mkdir -v -p ~/.themes

echo "Link: ~/.themes/retrosmart-openbox-themes-gold -> ~/.paps/openbox/retrosmart-openbox-themes-gold"
rm $rmflags ~/.themes/retrosmart-openbox-themes-gold
ln -sT ~/.paps/openbox/retrosmart-openbox-themes-gold ~/.themes/retrosmart-openbox-themes-gold

# parcellite
mkdir -v -p ~/.config/parcellite
echo "Link: ~/.config/parcellite/parcelliterc -> ~/.paps/parcellite/parcelliterc"
rm $rmflags ~/.config/parcellite/parcelliterc
ln -sT ~/.paps/parcellite/parcelliterc ~/.config/parcellite/parcelliterc

# vim
echo "Link: ~/.vimrc -> ~/.paps/vim/vimrc"
rm $rmflags ~/.vimrc
ln -sT ~/.paps/vim/vimrc ~/.vimrc

echo "Link: ~/.gvimrc -> ~/.paps/vim/gvimrc"
rm $rmflags ~/.gvimrc
ln -sT ~/.paps/vim/gvimrc ~/.gvimrc

echo "Link: ~/.vim -> ~/.paps/vim/vim"
rm $rmflags ~/.vim
ln -sT ~/.paps/vim/vim ~/.vim

# nvim
echo "Link: ~/.config/nvim -> ~/.paps/vim/vim"
rm $rmflags ~/.config/nvim
ln -sT ~/.paps/vim/vim ~/.config/nvim

# alacritty
mkdir -v -p ~/.config/alacritty
echo "Link: ~/.config/alacritty/alacritty.toml -> ~/.paps/alacritty/alacritty.toml"
rm $rmflags ~/.config/alacritty/alacritty.toml
ln -sT ~/.paps/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml

# zsh
echo "Link: ~/.zshrc -> ~/.paps/zsh/zshrc"
rm $rmflags ~/.zshrc
ln -sT ~/.paps/zsh/zshrc ~/.zshrc

echo "Link: ~/.zshenv -> ~/.paps/zsh/zshenv"
rm $rmflags ~/.zshenv
ln -sT ~/.paps/zsh/zshenv ~/.zshenv

echo "Link: ~/.inputrc -> ~/.paps/zsh/inputrc"
rm $rmflags ~/.inputrc
ln -sT ~/.paps/zsh/inputrc ~/.inputrc

# git
echo "Link: ~/.gitconfig -> ~/.paps/git/gitconfig"
rm $rmflags ~/.gitconfig
ln -sT ~/.paps/git/gitconfig ~/.gitconfig

# tmux
echo "Link: ~/.tmux.conf -> ~/.paps/tmux/tmux.conf"
rm $rmflags ~/.tmux.conf
ln -sT ~/.paps/tmux/tmux.conf ~/.tmux.conf

# htop
mkdir -v -p ~/.config/htop
echo "Link: ~/.config/htop/htoprc -> ~/.paps/htop/htoprc"
rm $rmflags ~/.config/htop/htoprc
ln -sT ~/.paps/htop/htoprc ~/.config/htop/htoprc
