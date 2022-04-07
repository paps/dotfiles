// Apparently this is needed for userChrome.css customizations to work
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.fixup.alternate.enabled", false);

// user_pref("mousewheel.default.delta_multiplier_y", 200);
// user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("extensions.pocket.enabled", false);
user_pref("browser.urlbar.trimURLs", false);

// Enable all extensions in private browsing too
// This flag is not supported anymore: https://superuser.com/questions/1669675/enable-all-firefox-extensions-in-private-mode-by-default
user_pref("extensions.allowPrivateBrowsingByDefault", true);

// don't sync extension's enabled/disabled status
user_pref("services.sync.addons.ignoreUserEnabledChanges", true);

// prevent things from moving all over the place
// calming the UI
user_pref("general.smoothScroll", false);
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("browser.fullscreen.animateUp", 0);
user_pref("ui.caretBlinkTime", 0);
user_pref("ui.scrollToClick", 1);
user_pref("nglayout.enable_drag_images", false);
user_pref("ui.prefersReducedMotion", 1);
user_pref("browser.download.animateNotifications", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("full-screen-api.warning.timeout", 0);

// wheel always scrolls, whatever the pressed modifier key
user_pref("mousewheel.with_alt.action", 1);
user_pref("mousewheel.with_shift.action", 1);
user_pref("mousewheel.with_control.action", 1);
user_pref("mousewheel.with_meta.action", 1);
user_pref("mousewheel.with_win.action", 1);

// force hardware acceleration (flaky?)
user_pref("layers.acceleration.force-enabled", true);
user_pref("gfx.webrender.all", true);

// only use memory cache, don't touch SSD (speeds things up? probably not)
user_pref("browser.cache.disk.enable", false);
user_pref("browser.cache.memory.enable", true);

// disable safe browsing (speeds things up just a little bit, but is it really necessary?)
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);

// Select light/dark mode depending on the OS setting (see gtk/settings3.ini)
// instead of the Firefox "inferred from theme colors". This is for websites.
user_pref("layout.css.prefers-color-scheme.content-override", 2);

// Make the Firefox UI light mode instead of "inferred from theme colors"
user_pref("browser.theme.content-theme", 1);
user_pref("browser.theme.toolbar-theme", 1);


// Make the scrollbars bigger
user_pref("widget.non-native-theme.gtk.scrollbar.round-thumb", false);
user_pref("widget.non-native-theme.gtk.scrollbar.thumb-size", 1);
user_pref("widget.non-native-theme.scrollbar.size.override", 14); // width in pixels
