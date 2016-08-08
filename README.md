Martin's dotfiles
=================

My dotfiles for Debian Sid.

Packages
--------

* Always install: `htop vim xauth git zsh tmux tree curl inotify-tools trash-cli wget`
* If possible: `neovim` (use `-t experimental` for `neovim`)
* For desktops/laptops:
	* Add: `p7zip-full unrar tig pv pydf zsh-doc vim-gtk vim-doc nmap zenmap whiptail obconf obmenu firefox gnome-terminal xterm xscreensaver dmenu feh numlockx conky-all scrot x11-xserver-utils acpi alsa-utils gksu stalonetray moc fontconfig vlc gitk xfonts-terminus libx11-dev build-essential xclip mplayer python3 libdatetime-perl gsimplecal gcalctool zenity virt-manager spice-client-gtk python-spice-client-gtk dunst geeqie geany thunar thunar-volman thunar-archive-plugin thunar-media-tags-plugin thunar-gtkhash file-roller unar arj lhasa rar lzip lzop ncompress rzip unace unalz zoo parcellite flashplugin-nonfree ttf-mscorefonts-installer libnotify-bin gparted transmission-remote-gtk gimp ssh-askpass evince zip unzip cmake python-dev xdotool redshift-gtk`
	* Remove: `notification-daemon`

SSH
---

* `ssh-keygen -t rsa -C "paps@[machine_name]"` (default location, strong passphrase)
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
* `cd dotfiles`
* Create all the required links: `./setup.sh [absolute-path-to-dotfiles]`

Shell
-----

* `whereis zsh`
* `chsh -s [absolute-path-to-shell]`

Neovim
------

* Only once, before first run: `git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle`
* Only once, to initialize plugins: `nvim -u ~/.paps/vim/bundles.vim +PluginInstall`
* For updating installed plugins: `nvim +PluginUpdate`
* For installing a new plugin added in `bundles.vim`: `nvim +PluginInstall`
* For removing unused plugins: `nvim +PluginClean`

Optional: Monitoring
--------------------

* x86 64/32: Go to https://newrelic.com, login, go to "Servers" and click "Add more".
* ARM: Go to https://manager.linode.com/longview, login, add a client.
* Go to https://papertrailapp.com, login, follow instructions to add a system.
	* Configure TLS encryption: http://help.papertrailapp.com/kb/configuration/encrypting-remote-syslog-with-tls-ssl/#rsyslog
	* Use better settings for the rsyslog queue: http://help.papertrailapp.com/kb/configuration/advanced-unix-logging-tips/#rsyslog_queue
	* Dont forget the `rsyslog-gnutls` package

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
* `sudo apt-get install htop chromium firefox geany`
* maybe package `libdbus-glib-1-2` is needed for firefox to work
* `sudo apt-get update`
* `cd ~ ; rm -fr Videos Pictures Music Documents Public Templates`
* `mkdir mnt`
* `sudo rm /etc/fonts/conf.d/70-no-bitmaps.conf` (allows bitmap fonts in the standard font list)

### Firefox

* Install LastPass: https://lastpass.com/download
* LastPass configuration:
	* "Automatically Logoff when all browsers are closed after 0 mins"
	* Disable all notifications
	* Uncheck:
		* "Highligh input boxes"
		* "Show vault after login"
		* "Automatically fill login information"
* Synchronize Firefox
* Install nightly Pentadactyl: http://5digits.org/pentadactyl/
* TreeStyleTab configuration:
	* Disable "narrow scrollbar", "collapse/expand trees", "indent tabs"
	* Theme: "Flat"
	* Set only one level of depth
	* Disable all context menu options except "Close this tree" and "Fix position and width"
	* Disable "Show tree contents in tooltips"
	* Auto hide: set "Show tab bar always" for normal window mode *and* full screen mode
* Search engines configuration:
	* `:dia searchengines`
	* Configure/add Google (set `g` as keyword)
	* Configure the rest as needed
	* In Preferences > Search: set Google as the default search engine
* Desktop notifications configuration:
	* Disable sounds
	* Enter sync key
* Rescue Time configuration:
	* Uncheck "already using the full rescue time app"
	* Enter email

### Configure openbox, conky, dunst

* `cd dotfiles/openbox`
* `cp rc.xml.dist rc.xml`
	* Set the dock floating position in `<dock>` (depends on the Xorg position and height of the left monitor) (or use `obconf` later and visually place the dock)
	* Optionally set the margins in `<margins>` (a 34px left or right margin is necessary for conky)
* `cp time_conkyrc.dist time_conkyrc`
	* Edit the first three lines
	* `gap_y` depends on the Xorg position of the left monitor, the default of 1 is fine in most cases
* `cp stats_conkyrc.dist stats_conkyrc`
	* Edit the first three lines
	* `gap_y` depends on the Xorg position of the left monitor, should be the same as `time_conkyrc` + 154
	* Identify the network interface to monitor (`downspeedf`, `downspeedgraph`, `upspeedf` and `upspeedgraph`)
	* If relevant, uncomment the battery section and identify it (`battery_short` and `battery_time`)
* `cp dunstrc.dist dunstrc`
	* Set `monitor` to `0`, `1` or `2` depending on where you want the notifications

### Session startup script

Optional startup script: `~/.paps/scripts/local.sh` (ignored by git, executed by `~/.paps/openbox/autostart.sh` on session start). Don't forget to `chmod +x`.

### GTK

* `sudo apt-get install lxappearance gnome-themes-standard`
* `rehash`
* `lxappearance`
* Select HighContrast widget theme and HighContrast icon theme

### Disable locking

To prevent xscreensaver from automatically locking the session: `touch ~/.paps/x/do_not_lock` (then restart X). For convenience, "Force lock" from the Openbox context menu still locks the session.

### Locales

`sudo dpkg-reconfigure locales`, add `fr_FR.utf8` if not present, make sure the default locale is `en_US.ut8`.

### Calendar, calculator

* `Ctrl-Alt-C` to open calendar
* `Ctrl-Alt-Y` to open calculator

### Multi-head AMD open-source driver setup (xserver-xorg-video-radeon package)

Dual monitor sample `xorg.conf`: `~/.paps/x/sample_radeon_dual_xorg.conf`

Triple monitor sample `xorg.conf`: `~/.paps/x/sample_radeon_triple_xorg.conf`

The most important thing to note is the use of an absolute `Position` in every `Monitor` section.
