#!/usr/bin/env bash

# arg number check
if [ $# -ne 1 ]
then
    echo "Usage: $0 /absolute/path/to/conf/git"
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

# server / desktop
while true; do
    read -p "server or desktop? " xinstall
    case $xinstall in
        server ) break;;
        desktop ) break;;
        * ) ;;
    esac
done

# dir
echo "Link: ~/.paps -> $1"
rm -ivr ~/.paps
ln -sT "$1" ~/.paps

if [ $xinstall = "desktop" ]; then

    # X11
    echo "Link: ~/.Xresources -> ~/.paps/x/.Xresources"
    rm -ivr ~/.Xresources
    ln -sT ~/.paps/x/Xresources ~/.Xresources

    echo "Link: ~/.xsession -> ~/.paps/x/.xsession"
    rm -ivr ~/.xsession
    ln -sT ~/.paps/x/xsession ~/.xsession

    echo "Link: ~/.xinitrc -> ~/.paps/x/.xsession"
    rm -ivr ~/.xinitrc
    ln -sT ~/.paps/x/xsession ~/.xinitrc

    echo "Link: ~/.Xmodmap -> ~/.paps/x/.Xmodmap"
    rm -ivr ~/.Xmodmap
    ln -sT ~/.paps/x/Xmodmap ~/.Xmodmap

    # pentadactyl
    echo "Link: ~/.pentadactylrc -> ~/.paps/pentadactyl/pentadactylrc"
    rm -ivr ~/.pentadactylrc
    ln -sT ~/.paps/pentadactyl/pentadactylrc ~/.pentadactylrc

    echo "Link: ~/.pentadactyl -> ~/.paps/pentadactyl/pentadactyl"
    rm -ivr ~/.pentadactyl
    ln -sT ~/.paps/pentadactyl/pentadactyl ~/.pentadactyl

    # icons
    echo "Link: ~/.icons -> ~/.paps/icons"
    rm -ivr ~/.icons
    ln -sT ~/.paps/icons ~/.icons

    # fonts
    echo "Link: ~/.fonts.conf -> ~/.paps/fonts/fonts.conf"
    rm -ivr ~/.fonts.conf
    ln -sT ~/.paps/fonts/fonts.conf ~/.fonts.conf

    echo "Link: ~/.fonts -> ~/.paps/fonts"
    rm -ivr ~/.fonts
    ln -sT ~/.paps/fonts ~/.fonts

    # openbox
    mkdir -p ~/.config/openbox

    echo "Link: ~/.config/openbox/menu.xml -> ~/.paps/openbox/menu.xml"
    rm -ivr ~/.config/openbox/menu.xml
    ln -sT ~/.paps/openbox/menu.xml ~/.config/openbox/menu.xml

    echo "Link: ~/.config/openbox/rc.xml -> ~/.paps/openbox/rc.xml"
    rm -ivr ~/.config/openbox/rc.xml
    ln -sT ~/.paps/openbox/rc.xml ~/.config/openbox/rc.xml

    echo "Link: ~/.config/openbox/autostart.sh -> ~/.paps/openbox/autostart.sh"
    rm -ivr ~/.config/openbox/autostart.sh
    ln -sT ~/.paps/openbox/autostart.sh ~/.config/openbox/autostart.sh

    mkdir -p ~/.themes

    echo "Link: ~/.themes/modern-grey -> ~/.paps/openbox/modern-grey"
    rm -ivr ~/.themes/modern-grey
    ln -sT ~/.paps/openbox/modern-grey ~/.themes/modern-grey

    # dunst
    mkdir -p ~/.config/dunst

    echo "Link: ~/.config/dunst/dunstrc -> ~/.paps/openbox/dunstrc"
    rm -ivr ~/.config/dunst/dunstrc
    ln -sT ~/.paps/openbox/dunstrc ~/.config/dunst/dunstrc

    # moc
    mkdir -p ~/.moc

    echo "Link: ~/.moc/config -> ~/.paps/moc/config"
    rm -ivr ~/.moc/config
    ln -sT ~/.paps/moc/config ~/.moc/config

    # gsimplecal
    mkdir -p ~/.config/gsimplecal

    echo "Link: ~/.config/gsimplecal/config -> ~/.paps/gsimplecal/config"
    rm -ivr ~/.config/gsimplecal/config
    ln -sT ~/.paps/gsimplecal/config ~/.config/gsimplecal/config

    # parcellite
    mkdir -p ~/.config/parcellite

    echo "Link: ~/.config/parcellite/parcelliterc -> ~/.paps/parcellite/parcelliterc"
    rm -ivr ~/.config/parcellite/parcelliterc
    ln -sT ~/.paps/parcellite/parcelliterc ~/.config/parcellite/parcelliterc

fi

# vim
echo "Link: ~/.vimrc -> ~/.paps/vim/.vimrc"
rm -ivr ~/.vimrc
ln -sT ~/.paps/vim/vimrc ~/.vimrc

echo "Link: ~/.vim -> ~/.paps/vim/.vim"
rm -ivr ~/.vim
ln -sT ~/.paps/vim/vim ~/.vim

# zsh
echo "Link: ~/.zshrc -> ~/.paps/zsh/.zshrc"
rm -ivr ~/.zshrc
ln -sT ~/.paps/zsh/zshrc ~/.zshrc

echo "Link: ~/.zshenv -> ~/.paps/zsh/.zshenv"
rm -ivr ~/.zshenv
ln -sT ~/.paps/zsh/zshenv ~/.zshenv

echo "Link: ~/.inputrc -> ~/.paps/zsh/.inputrc"
rm -ivr ~/.inputrc
ln -sT ~/.paps/zsh/inputrc ~/.inputrc

# git
echo "Link: ~/.gitconfig -> ~/.paps/git/gitconfig"
rm -ivr ~/.gitconfig
ln -sT ~/.paps/git/gitconfig ~/.gitconfig

# tmux
echo "Link: ~/.tmux.conf -> ~/.paps/tmux/.tmux.conf"
rm -ivr ~/.tmux.conf
ln -sT ~/.paps/tmux/tmux.conf ~/.tmux.conf

# htop
mkdir -p ~/.config/htop

echo "Link: ~/.config/htop/htoprc -> ~/.paps/htop/htoprc"
rm -ivr ~/.config/htop/htoprc
ln -sT ~/.paps/htop/htoprc ~/.config/htop/htoprc
