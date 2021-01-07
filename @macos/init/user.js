// Mozilla User Preferences

// Disables clipboard events to prevent clipboard spying
// Breaks CodeSandbox, temporarily disabled.
// user_pref("dom.event.clipboardevents.enabled", false);

// Use the New Cookie Jar policy, which prevents storage access for trackers
user_pref("network.cookie.cookieBehavior", 4);
// Disable DNS prefetching
user_pref("network.dns.disablePrefetch", true);
// Disable page prefetching
user_pref("network.prefetch-next", false);

// Enables first-party isolation, which prevents cross-site tracking and others.
// In practice it sometimes breaks SSO integrations.
user_pref("privacy.firstparty.isolate", true);

// Enables built-in tracking protection
user_pref("privacy.trackingprotection.enabled", true);
// Blocks cryptominers
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
// Blocks fingerprinting
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
