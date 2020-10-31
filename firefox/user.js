user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.fixup.alternate.enabled", false);
// user_pref("mousewheel.default.delta_multiplier_y", 200);
// user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("extensions.pocket.enabled", false);
user_pref("services.sync.addons.ignoreUserEnabledChanges", true); // don't sync extension's enabled/disabled status
user_pref("extensions.allowPrivateBrowsingByDefault", true); // enable all extensions in private browsing too
user_pref("browser.urlbar.trimURLs", false);
// user_pref("browser.display.background_color", "#155968"); // solarized dark background

// prevent things from moving all over the place
user_pref("general.smoothScroll", false);
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("browser.fullscreen.animateUp", 0);
user_pref("ui.caretBlinkTime", 0);
user_pref("ui.scrollToClick", 1);
user_pref("nglayout.enable_drag_images", false);
user_pref("ui.prefersReducedMotion", 1);

// wheel always scrolls, whatever the pressed modifier key
user_pref("mousewheel.with_alt.action", 1);
user_pref("mousewheel.with_shift.action", 1);
user_pref("mousewheel.with_control.action", 1);
user_pref("mousewheel.with_meta.action", 1);
user_pref("mousewheel.with_win.action", 1);

// force hardware acceleration (flaky?)
user_pref("layers.acceleration.force-enabled", true);
user_pref("gfx.webrender.all", true);

// only use memory cache
user_pref("browser.cache.disk.enable", false)
user_pref("browser.cache.memory.enable", true)
