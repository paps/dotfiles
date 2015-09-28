Martin's dotfiles ![project-status](http://stillmaintained.com/paps/dotfiles.png)
=================================================================================

My dotfiles for Debian Sid.

Packages
--------

* Always install: `htop vim git zsh tmux tree curl inotify-tools`
* For desktops/laptops:
	* Add: `p7zip-full unrar tig pv pydf zsh-doc vim-gtk vim-doc nmap zenmap whiptail obconf obmenu firefox xterm xscreensaver dmenu feh numlockx conky-all scrot x11-xserver-utils acpi alsa-utils gksu stalonetray moc fontconfig vlc gitk xfonts-terminus libx11-dev build-essential xclip mplayer python3 libdatetime-perl gsimplecal gcalctool zenity virt-manager spice-client-gtk python-spice-client-gtk dunst geeqie geany thunar thunar-volman thunar-archive-plugin thunar-media-tags-plugin thunar-gtkhash file-roller unar arj lhasa rar lzip lzop ncompress rzip unace unalz zoo parcellite flashplugin-nonfree ttf-mscorefonts-installer libnotify-bin gparted transmission-remote-gtk gimp ssh-askpass`
	* Remove: `notification-daemon`

SSH
---

* `ssh-keygen -t rsa -b 4096 -C "paps@[machine_name]"` (default location, strong passphrase)
* add key to GitHub: https://github.com/settings/ssh
* `scp ~/.ssh/id_rsa.pub paps@[box]:`
* `ssh [box]`
	* add key in gitolite-admin repository, commit, push
	* add key in dotssh repository, commit, push
	* `rm id_rsa.pub`
* `git clone git@[box]:dotssh`
	* `./setup.sh [absolute-path-to-dotssh]`

Install the dotfiles
--------------------

* `git clone git@github.com:paps/dotfiles.git`
* Create all the required links: `./setup.sh [absolute-path-to-dotfiles]`

Shell
-----

* `whereis zsh`
* `chsh -s [absolute-path-to-shell]`

Vim
---

* Only once, before first run: `git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle`
* Only once, to initialize plugins: `vim -u ~/.paps/vim/bundles.vim +PluginInstall`
* For updating installed plugins: `vim +PluginUpdate`
* For installing a new plugin added in `bundles.vim`: `vim +PluginInstall`
* For removing unused plugins: `vim +PluginClean`

New Relic
---------

Go to https://newrelic.com, login, go to "Servers" and click "Add more".

Local binaries
--------------

Add local binaries in `~/.paps/bin` (it's in $PATH).

Desktops/Laptops
----------------

### From nothing to a minimal, configurable setup

Debian testing netinst from http://cdimage.debian.org/cdimage/weekly-builds/

Easiest way to make a bootable usb disk: `sudo umount [...]` then `sudo cp debian.iso /dev/sdX`

Install settings: full disk encryption, no root password, user `paps` in sudoers, `en_US.utf8` locale, `American English` keyboard, no additionnal packages except `Standard system utilities`, `SSH server` and optionally `Laptop` (if available).

Optimal setup procedure:

* `sudo apt-get install vim`
* `sudo vim /etc/apt/sources.list`
	* `deb http://[mirror_url]/debian/ sid main contrib non-free`
	* `deb http://[mirror_url]/debian/ experimental main contrib non-free`
* `sudo apt-get update`
* `sudo apt-get dist-upgrade`
* `sudo apt-get install xinit openbox xterm`
* for VMs: install `virtualbox-guest-x11` (VirtualBox) or `spice-vdagent` (virt-manager...)
* `exec startx`
* `sudo apt-get install htop chromium`
* add Linux Mint repository and PGP key: https://thestandardoutput.com/posts/install-the-real-firefox-on-debian-7/
* `sudo apt-get update`
* `sudo apt-get install firefox (+ libdbus-glib-1-2 ?) geany`
* `rm -fr Videos Pictures Music Documents Public Templates`
* `mkdir mnt`

### Firefox

* Install LastPass: https://lastpass.com/download
* LastPass configuration: "Automatically Logoff when all browsers are closed after 0 mins", disable all notifications
* Synchronize Firefox
* Install Pentadactyl: http://5digits.org/pentadactyl/
* Bookmark Tab configuration: set body background-color to `#dddddd` and body max-width to `250px`, replace `Tahoma` fonts with `Monaco`, set "Source" to "Menu" only and check "Load overview" and "Preserve state of opened folders", uncheck all other checkboxes
* TreeStyleTab configuration:
	* *Disable* "narrow scrollbar", "collapse/expand trees", "indent tabs"
	* Theme: "Flat"
	* Tree twisties: "None"
	* *Disable all context menu options* except "Close this tree" and "Fix position and width"
	* *Disable* "Show tree contents in tooltips"
	* Auto hide: set "Show tab bar always" for normal window mode *and* full screen mode
* Search engines configuration: `:dia searchengines`, remove all search engines except Google (set `g` as keyword) and Wikipedia (set `w` as keyword) (add other search engines and keywords as needed)
* Desktop notifications configuration: disable sounds, enter sync key
* Rescue Time configuration: enter email, uncheck "already using the full rescue time app"

### Session startup script

Optional startup script: `~/.paps/scripts/local.sh` (ignored by git, executed by `~/.paps/openbox/autostart.sh` on session start). Don't forget to `chmod +x`.

### Disabling locking

To prevent xscreensaver from automatically locking the session: `touch ~/.paps/x/do_not_lock` (then restart X). For convenience, "Force lock" from the Openbox context menu still locks the session.

### Calendar & calculator

* `dpkg-reconfigure locales`, add `fr_FR.utf8` if not present, dot not change default locale (should be `None`)
* `Ctrl-Alt-C` to open calendar
* `Ctrl-Alt-Y` to open calculator

Dual monitors (two openbox processes)
-------------------------------------

### Generate openbox configuration for the other display

`~/.paps/openbox/generate_nomargin_xml.sh`

### Mouse switcher

* `~/.paps/openbox/make_switchscreen.sh`
* Use `Ctrl-Alt-Tab` to switch screens

### Order of displays

Edit `~/.paps/x/display_order` to control the order in which Openbox sessions are started (maximum of two monitors for now).

It must contain a single line with two space separated X display addresses.

In practice, there are two possibilities for the content of this optional file:

	:0.1 :0.0

or

	:0.0 :0.1

This file is read by `~/.paps/x/xsession` and is ignored by git.
