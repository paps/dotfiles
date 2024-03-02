Martin's dotfiles
=================

My Debian Sid dotfiles for desktops or laptops. For a minimal server configuration, use https://github.com/paps/dotfiles-server

### Shortcuts

Once everything is configured correctly, these useful shortcuts are available:

Sound
* `Ctrl-Alt-[` to lower sound volume
* `Ctrl-Alt-]` to increase sound volume
* `Ctrl-Alt-\` to mute/unmute sound
* `WheelUp`/`WheelDown` with the cursor positionned at the top pixel row to lower/increase sound volume

Apps
* `Ctrl-Alt-c` to open calendar
* `Ctrl-Alt-y` to open calculator
* `Ctrl-Alt-s` to take a screenshot
* `Ctrl-Alt-t` to spawn a terminal

Desktop environment
* `Alt-F1` to open the window switcher
* `Alt-F2` to open rofi (app launcher)
* `Alt-F3` to open the Openbox menu
* `Ctrl-Alt-l` to lock (with password, different from just letting the screen go to sleep)
* `Ctrl-WheelUp`/`Ctrl-WheelDown` with the cursor positionned at the top pixel row to lower/increase screen brightness

Window management
* `Alt-F10` to maximize/unmaximize the focused window
* `Alt-Space` to open the window contextual menu
* `Ctrl-Alt-d` to collapse all windows (go to desktop)
* To go from one desktop to another:
	* `Ctrl-Alt-HorizontalWheelUp`/`Ctrl-Alt-HorizontalWheelUp` or
	* `Ctrl-Alt-Left`/`Ctrl-Alt-Right` or
	* `Ctrl-Alt-j`/`Ctrl-Alt-k`

Tiling
* `Ctrl-Alt-Home` or `Ctrl-Alt-MousePrev`: vertical split, left side
* `Ctrl-Alt-End` or `Ctrl-Alt-MouseNext`: vertical split, right side
* `Ctrl-Alt-PageUp`: horizontal split, top side
* `Ctrl-Alt-PageDown`: horizontal split, bottom side

Text editing
* `Ctrl-Alt-f` to open the clipboard menu
* `Ctrl-Alt-g` to switch input method (e.g. EN/CN)
* `Ctrl-.` to insert an emoji (input field)
* `Super-H`/`Super-J`/`Super-K`/`Super-L` can be used instead of arrow keys
* `Ctrl-Alt-1` to insert current date and time

### Install

Debian testing netinst from http://cdimage.debian.org/cdimage/weekly-builds/ (or even better, take one that includes non-free firmware: http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/weekly-builds/amd64/iso-cd/)

Easiest way to make a bootable usb disk: `sudo umount [...]` then `sudo cp debian.iso /dev/sdX`

Install settings: full disk encryption, no root password, user `paps` in sudoers, `en_US.utf8` locale, `American English` keyboard, no additionnal packages except `Standard system utilities`and optionally `SSH server` and `Laptop` (if available).

Optimal setup procedure:

* `sudo apt install vim`
* `sudo vim /etc/apt/sources.list`
	* `deb http://deb.debian.org/debian sid main contrib non-free`
	* `deb http://deb.debian.org/debian experimental main contrib non-free`
* `sudo apt update`
* `sudo apt dist-upgrade`
* `sudo apt install xinit openbox xterm`
* `exec startx`
* `sudo apt install htop chromium firefox geany`
* `cd ~ ; rm -fr Videos Pictures Music Documents Desktop Public Templates`
* `sudo rm /etc/fonts/conf.d/70-no-bitmaps.conf` (allows bitmap fonts in the standard font list)

### Packages

* Install base packages: `bc psmisc htop neovim vim xauth git zsh tmux tree curl inotify-tools trash-cli wget dnsutils apache2-utils p7zip-full unrar tig pv pydf zsh-doc vim-doc nmap whiptail obconf firefox gnome-terminal xterm suckless-tools feh numlockx conky-all x11-xserver-utils acpi acpid alsa-utils stalonetray fontconfig gitk libx11-dev build-essential xclip python3 libdatetime-perl zenity thunar thunar-volman thunar-archive-plugin thunar-media-tags-plugin thunar-gtkhash file-roller unar arj lhasa lzip lzop ncompress rzip unace unalz parcellite libnotify-bin ssh-askpass evince zip unzip cmake xdotool redshift pavucontrol rsync network-manager network-manager-gnome e2fsprogs logsave arandr dbus-x11 apt-transport-https ca-certificates gnupg2 software-properties-common ibus-libpinyin lemonbar rofi`
* Install fonts: `xfonts-terminus fonts-croscore fonts-noto-color-emoji ttf-mscorefonts-installer fonts-inter fonts-inter-variable fonts-hack fonts-open-sans`
* Install themes: `mate-themes gtk2-engines greybird-gtk-theme elementary-xfce-icon-theme`
* Install utilities: `gnome-screenshot peek gpicview ansible scrot vlc mplayer gparted transmission-remote-gtk gimp gsimplecal qalculate geany`
* Recommended: `intel-microcode amd64-microcode firmware-linux` (other firmware packages might be necessary)
* Remove: `notification-daemon xsel`

### SSH key

* `ssh-keygen -t rsa -C "paps@[machine_name]"` (default location, strong passphrase)
* Add key to GitHub: https://github.com/settings/ssh
* (Now is a good time to remove old keys from GitHub.)

**Deploying the new SSH key**

First of all, make sure all keys stored on GitHub are still valid and that each one corresponds to a known, live, accessible, owned device. Beware of keys added by tools (e.g. CircleCI) — these MUST be moved to a [GitHub machine user](https://docs.github.com/en/developers/overview/managing-deploy-keys#machine-users), we don't want to give tools access to all our machines.

Then, proceed by SSHing into all relevant managed machines and execute `curl 'https://github.com/paps.keys' > ~/.ssh/authorized_keys && cat ~/.ssh/authorized_keys` on each. (The `cat` command is added to visually confirm we're not losing access to the machine by mistake.)

### SSH server

**Important:** Set `PasswordAuthentication` to `no` in `/etc/ssh/sshd_config`.

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

### Solaar

If using a wireless device of the "Logitech unifying" type, it's a good idea to install `solaar`, at least to be aware of the device battery level.

Run `sudo apt install solaar`.

`solaar` is automatically started by openbox's `autostart.sh` when it is detected as installed.

### Node & NPM

If needed, install Node from a Nodesource Debian distribution: https://github.com/nodesource/distributions

Great to have globally: `sudo npm install -g jsonlint typescript uglify-js http-server eslint neovim phantombuster-sdk`

After having installed TypeScript, for completion support, do this: `cd ~/.vim/bundle/nvim-typescript ; ./install.sh`

If you want to have a Node binary from Nodesource of a lower version than what's available in the Debian unstable repos, use pinning, e.g. edit `/etc/apt/preferences.d/99priority-to-nodesource` with this:
```
Package: *
Pin: origin deb.nodesource.com
Pin-Priority: 1001
```

### Local binaries

Add local binaries in `~/.paps/bin` (it's in $PATH).

### Firefox

* Install Bitwarden: https://bitwarden.com/download/
* Bitwarden configuration (most defaults are fine except these):
	* Set "Clear clipboard" to 5 minutes
	* Don't show cards on tag page
	* Don't show identities on tab page
	* Disable context menu otions
* Synchronize Firefox
* Remove URL bookmark star shortcut (right click)
* Go into the default profile folder `~/.mozilla/firefox/XXXX.default-release` then:
	* `mkdir chrome`
	* `ln -s ~/.paps/firefox/userChrome.css chrome/`
	* `ln -s ~/.paps/firefox/userContent.css chrome/`
	* `ln -s ~/.paps/firefox/user.js .`
	* Firefox needs to be restarted for these to be taken into account
* In "customize mode", remove URL bar spacers, enable Solarized fox theme, etc
	* Select compact density (this is only possible after applying `user.js`)
* Stylus configuration:
	* Go to options and enable `Sync to cloud` with personal Google Drive
* uBlock configuration:
	* In the "Settings" tab:
		* Tick "Enable cloud storage support"
		* Untick "Make use of context menu where appropriate"
	* In the "Filter lists" tab:
		* Set the machine's name (top-right cogwheel)
		* Pull the lists from cloud storage

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

**Asahi:** Special `.notch.dist` conky templates are available, these should be used as a starting point instead. Use `obconf` to adjust dock position and margins (a 60px top margin seems perfect).

### Desktop notifications

* `apt install xfce4-notifyd`
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
		* Normal size: Ctrl+0
	* Profiles: just one profile
* Profile preferences
	* Text
		* Custom font: Hack Nerd Font Mono Regular 9
		* Cursor shape: block
		* Disabled cursor blinking
		* No terminal bell
	* Colors
		* Dont use colors from system
		* Built-in scheme: Solarized light
		* Palette: Solarized
	* Scrolling
		* No scrollbar
		* Dont scroll on output
		* Scroll on keystroke
		* Limit scrollback to 10000 lines
	* Command:
		* Run custom command instead of shell: `tmux`
	* Compatibility: the default
* Useful to know: `gnome-terminal --show-menubar` and shift-right-click for context menu

### Session startup script(s)

**For the current user:** Optional startup script `~/.paps/scripts/local.sh` (ignored by git, executed by `~/.paps/openbox/autostart.sh` on session start). Don't forget to `chmod +x` when creating this file.

**As root:** Edit `~/.paps/scripts/root-boot.sh` as needed, then run `sudo contrab -e` and add this line `@reboot sleep 5 && /home/paps/.paps/scripts/root-boot.sh` (assuming `paps` is the current user) (a sleep is added as a cheap workaround to wait for most things to be ready, daemons to be loaded, etc).

### Screensaving

In `openbox/xcfg.sh`, we make X make the screen black at 10min then shut it down at 11min.

Useful for TVs: `touch ~/.paps/x/screensaver_4h` to make the screensaver wait 4 hours before activating.

`Ctrl-Alt-l` and "Lock" from the Openbox context menu will call `slock` which will lock the screen and will wait for the correct password to be entered.

### Locales

`sudo dpkg-reconfigure locales`, add `fr_FR.utf8` if not present, make sure the default locale is `en_US.ut8`.

### Timezone

Use `sudo dpkg-reconfigure tzdata` to change timezone. A change like this should come with a change to redshift configuration, see `openbox/autostart.sh`.

### Force default browser

* `sudo update-alternatives --config x-www-browser` and select Firefox
* `xdg-settings set default-web-browser firefox.desktop`

### IBus input methods

By default ibus-daemon comes with `Super-Space` as a shortcut to switch between input methods (e.g. between EN and CN). This doesn't work because it conflicts with the xmodmap settings.

To fix, go into IBus preferences, and changes the "Next input method" setting to `<Control><Alt>g`.

Change simplified to traditional

Change emoji to control period
Enable fuzzy matching on 3 characters any match
Enable cloud pinyin input

### NextDNS

Install NextDNS' CLI client: https://github.com/nextdns/nextdns/wiki/Debian-Based-Distribution

Do `sh -c "$(curl -sL https://nextdns.io/install)"` then enable 'report device name', enable 'hardened privacy mode', disable 'setup as router' and enable 'Automatically configure host DNS on daemon startup'.

By default, `dhclient` is probably running on the machine, which means that the `127.0.0.1` DNS server set in `/etc/resolv.conf` by NextDNS will be overridden regularly. To continue using both the local NextDNS server and `dhclient` at the same time, edit `/etc/dhcp/dhclient.conf` and make sure to uncomment (or add) the following line: `prepend domain-name-servers 127.0.0.1;`

To target NextDNS' configuration on poorly configurable devices (e.g. a Samsung TV) behind the same NAT as a desktop PC, the public IP is bound thanks to a crontab entry similar to this one: `21 */4 * * * curl --fail --silent --show-error 'https://link-ip.nextdns.io/xxxxxx/yyyyyyyyyyyyyyyyy' 2>&1 | logger -t nextdnslinkip`.

### Obsidian

Get it from https://obsidian.md/ (Asahi: get the AppImage because they don't have an ARM deb). Once installed, enable sync.

**Important:** in the settings, go to 'Sync' and check all the boxes (sync files of all types, sync all configuration), and then restart Obsidian.

Other settings to change in 'Appearance': do use 'Native menus', do use 'Native frame'.

### Network Manager

The NetworkManager service is not enabled by default on Debian. Normally for normal desktop PCs this would not be needed as they just connect via their wired iface automatically, but it's great to have a graphical UI for controlling some network settings.

In order to enable the NetworkManager service:
* change `managed=false` to `managed=true` in `/etc/NetworkManager/NetworkManager.conf` to let it manage wired interfaces
* run `sudo systemctl enable NetworkManager` (and `sudo systemctl start NetworkManager` the first time)

### Bluetooth

Install `bluetooth bluez-firmware blueman` and restart. When there is a need to pair to something, run `blueman-applet`.

### Mouse acceleration

Before `libinput` existed, the `xset m` command found in `openbox/xcfg.sh` had an effect. Now it's a no-op.

To disable mouse acceleration, copy `x/configs/40-mouse.conf` in `/etc/X11/xorg.conf.d/`.

### Laptops (non-Asahi)

`x/configs/20-intel.conf` is an example of a good integrated Intel Graphics configuration. `x/configs/30-touchpad.conf` is an example of a good touchpad configuration. Copy these to `/etc/X11/xorg.conf.d/` to use them.

Use `tlp` for battery optimizations: http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html

* `apt install tlp tlp-rdw`
* `service tlp start`
* `service tlp status`
* `tlp-stat -s`

Use `powertop` for monitoring power usage (however, when used in parallel with `tlp`, some of the information displayed seems wrong, beware).

* `apt install powertop`

Intel driver provided by package `xserver-xorg-video-intel` is deprecated and should not be used on any recent hardware. The newer alternative is referred to as the Modesetting driver. Use that.

### Laptop screen backlight control

* Install `brightnessctl brightness-udev`
* Run `sudo usermod -a -G video paps` (assuming `paps` is the current user)
* Logout/login as a group membership was changed
* Screen backlight controls should now be working

### High DPI

* `touch ~/.paps/x/dpi144` then restart X for 50% more pixels
* `touch ~/.paps/x/dpi168` then restart X for 75% more pixels
* `touch ~/.paps/x/dpi192` then restart X for 100% more pixels

The `xsession` defines a `$dpi` variable according to the precense of this file, which is then passed to `Xresources`.

### Apple keyboards

* Respect standard layout: `# echo 0 > /sys/module/hid_apple/parameters/iso_layout`
* Have ctrl & alt were it's expected: `# echo 1 > /sys/module/hid_apple/parameters/swap_opt_cmd`
* F keys are F keys: `# echo 2 > /sys/module/hid_apple/parameters/fnmode`

If such a keyboard is present at boot (e.g. it's not a bluetooth keyboard), these options should already be set by `scripts/root-boot.sh` — no intervention required, provided the script is correctly launched by cron on @reboot.

### White noise focus

* Download white noise mp3 file: https://drive.google.com/file/d/1CduNogudNJpVzJ4-Y575vCMWpOzTVW61
* Then: `cvlc --start-time=300 --stop-time=1500 --repeat noise.mp3`

### Keybase

* Keybase can be installed from here: https://keybase.io/docs/the_app/install_linux#ubuntu-debian-and-friends
* Then, to start it: `run_keybase`
* To completely stop it: `keybase ctl stop`
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

### Notification of jack plugged in/plugged out

In `/etc/acpi/events/notify-jack` (this is a new file), put the following:
```
event=jack/.*
action=su paps -c 'bash /home/paps/.paps/openbox/publish-notification.sh "%%{r}%e"'
```

