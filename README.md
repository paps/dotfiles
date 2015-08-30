Martin's dotfiles ![project-status](http://stillmaintained.com/paps/dotfiles.png)
=================================================================================

My dotfiles for Debian Sid.

Desktop / laptop
----------------

### From nothing to a minimal, configurable setup

Debian testing netinst from http://cdimage.debian.org/cdimage/weekly-builds/

Easiest way to make a bootable usb disk: `umount [...]` then `sudo cp debian.iso /dev/sdX`

Install settings: full disk encryption, no root password, user `paps` in sudoers, no additionnal packages except "Standard system utilities", "SSH server" and optionally "Laptop" (if available).

Optimal setup procedure:
* `sudo apt-get install vim`
* `sudo vim /etc/apt/sources.list`
	deb http://[mirror_url]/debian/ sid main contrib non-free
	deb http://[mirror_url]/debian/ experimental main contrib non-free
* `sudo apt-get update`
* `sudo apt-get dist-upgrade`
* `sudo apt-get install xinit openbox xterm htop`
* for VMs: install `virtualbox-guest-x11` (VirtualBox) or `spice-vdagent` (virt-manager...)
* `exec startx`
* add Linux Mint repository and PGP key: https://thestandardoutput.com/posts/install-the-real-firefox-on-debian-7/
* `sudo apt-get update`
* `sudo apt-get install firefox (+ libdbus-glib-1-2 ?) geany`
* `rm -fr Videos Pictures Music Documents Public Templates`

### Packages

* Install: `htop nmap vim vim-gtk most screen whiptail zsh tmux build-essential p7zip-full unrar tree git tig pv pydf curl zsh-doc vim-doc obconf obmenu firefox xterm zenmap xscreensaver dmenu feh numlockx conky-all scrot x11-xserver-utils acpi alsa-utils gksu stalonetray moc fontconfig vlc gitk xfonts-terminus libx11-dev build-essential xclip mplayer pv python3 libdatetime-perl gsimplecal gcalctool zenity virt-manager spice-client-gtk python-spice-client-gtk geeqie geany thunar pcmanfm dunst`
* Remove: `notification-daemon`

### Firefox

* Install LastPass: https://lastpass.com/download

### SSH

* `ssh-keygen -t rsa -b 4096 -C "paps@[machine_name]"` (default location, strong passphrase)
* `scp ~/.ssh/id_rsa.pub paps@[box]:`
* `ssh [box]`
* add key in gitolite admin repository, commit, push
* add key in ssh repository, commit, push
* add key to GitHub: https://github.com/settings/ssh
* `rm [box]:id_rsa.pub`

### Dual monitors

Edit `~/.paps/x/display_order` to control the order in which openbox sessions are started (maximum of two monitors for now).

It must contain a single line with two space separated X display addresses.

In practice, there are two possibilities for the content of this optional file:

	:0.1 :0.0

or

	:0.0 :0.1

This file is read by `~/.paps/x/xsession` and is ignored by git.

Server
------
