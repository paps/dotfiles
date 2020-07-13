Martin's dotfiles
=================

My Debian Sid dotfiles for desktops or laptops. For a minimal server configuration, use https://github.com/paps/dotfiles-server

### Install

Debian testing netinst from http://cdimage.debian.org/cdimage/weekly-builds/ (or even better, take one that includes non-free firmware: http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/weekly-builds/amd64/iso-cd/)

Easiest way to make a bootable usb disk: `sudo umount [...]` then `sudo cp debian.iso /dev/sdX`

Install settings: full disk encryption, no root password, user `paps` in sudoers, `en_US.utf8` locale, `American English` keyboard, no additionnal packages except `Standard system utilities`, `SSH server` and optionally `Laptop` (if available).

Optimal setup procedure:

* `sudo apt-get install vim`
* `sudo vim /etc/apt/sources.list`
	* `deb http://deb.debian.org/debian sid main contrib non-free`
	* `deb http://deb.debian.org/debian experimental main contrib non-free`
* `sudo apt-get update`
* `sudo apt-get dist-upgrade`
* `sudo apt-get install xinit openbox xterm`
* for VMs: install `virtualbox-guest-x11` (VirtualBox) or `spice-vdagent` (virt-manager...)
* `exec startx`
* `sudo apt-get install htop chromium firefox geany`
* `cd ~ ; rm -fr Videos Pictures Music Documents Desktop Public Templates`
* `sudo rm /etc/fonts/conf.d/70-no-bitmaps.conf` (allows bitmap fonts in the standard font list)

### Packages

* Install: `htop neovim vim xauth git zsh tmux tree curl inotify-tools trash-cli wget dnsutils apache2-utils p7zip-full unrar tig pv pydf zsh-doc vim-gtk vim-doc nmap zenmap whiptail obconf obmenu firefox gnome-terminal xterm xscreensaver dmenu feh numlockx conky-all scrot x11-xserver-utils acpi alsa-utils stalonetray fontconfig vlc gitk xfonts-terminus fonts-croscore libx11-dev build-essential xclip mplayer python3 libdatetime-perl gsimplecal gnome-calculator zenity virt-manager spice-client-gtk geany thunar thunar-volman thunar-archive-plugin thunar-media-tags-plugin thunar-gtkhash file-roller unar arj lhasa rar lzip lzop ncompress rzip unace unalz parcellite flashplugin-nonfree ttf-mscorefonts-installer libnotify-bin gparted transmission-remote-gtk gimp ssh-askpass evince zip unzip cmake python-dev xdotool redshift-gtk pavucontrol volumeicon-alsa apt-transport-https rsync network-manager network-manager-gnome e2fsprogs logsave arandr dbus-x11 gnome-screenshot apt-transport-https ca-certificates gnupg2 software-properties-common lemonbar rofi peek gpicview mate-themes`
* Recommended: `intel-microcode firmware-linux` (other firmware packages might be necessary)
* Remove: `notification-daemon xsel`

### SSH

* `ssh-keygen -t rsa -C "paps@[machine_name]"` (default location, strong passphrase)
* add key to GitHub: https://github.com/settings/ssh

### Install the dotfiles

* `git clone git@github.com:paps/dotfiles.git`
* `cd dotfiles`
* Create all the required links: `./setup.sh [absolute-path-to-dotfiles]`

### Shell

* `whereis zsh`
* `chsh -s [absolute-path-to-shell]`

### Neovim

* Only once, before first run: `git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle`
* Only once, to initialize plugins: `nvim -u ~/.paps/vim/bundles.vim +PluginInstall`
* For updating installed plugins: `nvim +PluginUpdate`
* For installing a new plugin added in `bundles.vim`: `nvim +PluginInstall`
* Often needed after updates or installs: `nvim +UpdateRemotePlugins`
* For removing unused plugins: `nvim +PluginClean`

### Optional: Monitoring

* **TODO**: Describe collectd install
* Go to https://papertrailapp.com, login, follow instructions to add a system.
	* Configure TLS encryption: http://help.papertrailapp.com/kb/configuration/encrypting-remote-syslog-with-tls-ssl/#rsyslog
	* Use better settings for the rsyslog queue: http://help.papertrailapp.com/kb/configuration/advanced-unix-logging-tips/#rsyslog_queue
	* Dont forget the `rsyslog-gnutls` package

### Rescuetime

Go to https://www.rescuetime.com/dashboard and install the Debian package. It is automatically started by `~/.paps/openbox/autostart.sh`.

### Node & NPM

If needed, install Node from a Nodesource Debian distribution: https://github.com/nodesource/distributions

Great to have globally: `sudo npm install -g jsonlint typescript uglify-js http-server eslint tslint neovim phantombuster-sdk`

After having installed TypeScript, for completion support, do this: `cd ~/.vim/bundle/nvim-typescript ; ./install.sh`

### Local binaries

Add local binaries in `~/.paps/bin` (it's in $PATH).

### Firefox

* Install LastPass: https://lastpass.com/download
* LastPass configuration:
	* "Automatically Logoff when all browsers are closed after 0 mins"
	* Disable all notifications
	* Uncheck:
		* "Highlight input boxes"
		* "Show vault after login"
		* "Automatically fill login information"
* Synchronize Firefox
* Go into the default profile folder `~/.mozilla/firefox/XXXX.default` then:
	* `mkdir chrome`
	* `ln -s ~/.paps/firefox/userChrome.css chrome/`
	* `ln -s ~/.paps/firefox/userContent.css chrome/`
	* `ln -s ~/.paps/firefox/user.js .`
* Rescue Time configuration (if asked):
	* Check "already using the full rescue time app"
	* Enter email
* Stylus configuration:
	* Go to options and enable `Sync to cloud` with personal Google Drive

### Configure openbox & conky

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

### Desktop notifications

* `apt-get install xfce4-notifyd`
* `xfce4-notifyd-config`
	* Theme: Default
	* Default position: Bottom right
	* Disappear after: 10s
	* Opacity: 100%

### Gnome terminal

* Preferences
	* General
		* Uncheck all
		* Theme: default
		* Allow blinking text: never
	* Shortcuts, everything disabled except:
		* Zoom in: Ctrl++
		* Zoom out: Ctrl+_
		* Normal size: Ctrl+)
	* Profiles: just one profile
	* Encodings: just utf-8 unicode
* Profile preferences
	* General
		* Cursor shape: block
		* No terminal bell
		* Custom font: Ttyp0 Regular of size 10
	* Command:
		* Run custom command instead of shell: `tmux`
	* Colors
		* Dont use colors from system
		* Built-in scheme: Solarized light
		* Palette: Solarized
	* Scrolling
		* No scrollbar
		* Dont scroll on output
		* Scroll on keystroke
		* Limit scrollback to 10000 lines
	* Compatibility: the default
* Useful to know: `gnome-terminal --show-menubar`

### Session startup script

Optional startup script: `~/.paps/scripts/local.sh` (ignored by git, executed by `~/.paps/openbox/autostart.sh` on session start). Don't forget to `chmod +x`.

### Disable locking

To prevent xscreensaver from automatically locking the session: `touch ~/.paps/x/do_not_lock` (then restart X). For convenience, "Lock" from the Openbox context menu still locks the session.

### Locales

`sudo dpkg-reconfigure locales`, add `fr_FR.utf8` if not present, make sure the default locale is `en_US.ut8`.

### Force default browser

* `sudo update-alternatives --config x-www-browser` and select Firefox
* `xdg-settings set default-web-browser firefox.desktop`

### Openbox shortcuts

* `Ctrl-Alt-C` to open calendar
* `Ctrl-Alt-Y` to open calculator
* `Ctrl-Alt-S` to take a screenshot

### NextDNS

Install NextDNS' CLI client: https://github.com/nextdns/nextdns/wiki/Debian-Based-Distribution

Do `sh -c "$(curl -sL https://nextdns.io/install)"` then enable 'report device name', enable 'hardened privacy mode', don't 'setup as router' and enable 'Automatically configure host DNS on daemon startup'.

To target NextDNS' configuration on poorly configurable devices (e.g. a Samsung TV) behind the same NAT as a desktop PC, the public IP is bound thanks to a crontab entry similar to this one: `21 */4 * * * curl --fail --silent --show-error 'https://link-ip.nextdns.io/xxxxxx/yyyyyyyyyyyyyyyyy' 2>&1 | logger -t nextdnslinkip`.

### Multi-head AMD open-source driver setup (xserver-xorg-video-radeon package)

Dual monitor sample `xorg.conf`: `x/radeon/dual_xorg.conf`

Triple monitor sample `xorg.conf`: `x/radeon/triple_xorg.conf`

The most important thing to note is the use of an absolute `Position` in every `Monitor` section.

### Laptops

See `x/laptop/` folder for examples of X11 configuration for laptops (Intel Graphics, touchpad and removal of mouse acceleration). To use, put them in `/etc/X11/xorg.conf.d/` (folder might need to be created).

Use `tlp` for battery optimizations: http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html

* `apt-get install tlp tlp-rdw`
* `service tlp start`
* `service tlp status`
* `tlp-stat -s`

Use `powertop` for monitoring power usage (however, when used in parallel with `tlp`, some of the information displayed seems wrong, beware).

* `apt-get install powertop`

### High DPI

To switch to 144 instead of the default of 96: `touch ~/.paps/x/dpi144` (then restart X). The `xsession` defines a `$dpi` variable according to the precense of this file, which is then passed to `Xresources`. Another option is 192: `touch ~/.paps/x/dpi192`.

### Apple Wireless Keyboard

* Respect standard layout: `# echo 0 > /sys/module/hid_apple/parameters/iso_layout`
* Have ctrl & alt were it's expected: `# echo 1 > /sys/module/hid_apple/parameters/swap_opt_cmd`
* F keys are F keys: `# echo 2 > /sys/module/hid_apple/parameters/fnmode`

### White noise focus

* Download white noise mp3 file: https://drive.google.com/file/d/1CduNogudNJpVzJ4-Y575vCMWpOzTVW61
* Then: `cvlc --start-time=300 --stop-time=1500 --repeat noise.mp3`

### Keybase

* Keybase can be installed from here: https://keybase.io/docs/the_app/install_linux#ubuntu-debian-and-friends
* Then: `run_keybase`
* Do no forget to disable autostart with `keybase ctl autostart --disable` (https://keybase.io/docs/linux-user-guide#autostart)

### Linux kernel config

Add the following lines to `/etc/sysctl.conf`:
```
# --- Personal dotfiles settings below ---
# Debian's default of 8192 is easily hit, we want to be able to watch more files
fs.inotify.max_user_watches=524288
# Much more aggresive TCP "link down" detection (~30s instead of 1+h)
net.ipv4.tcp_keepalive_time=10
net.ipv4.tcp_keepalive_intvl=10
net.ipv4.tcp_keepalive_probes=2
net.ipv4.tcp_retries2=6
```
