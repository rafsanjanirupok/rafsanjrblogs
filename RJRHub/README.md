# RJR Hub

A minimal, full-screen iOS wrapper app for **https://rafsanjanirupok.com/**
No address bar, no toolbar, no on-screen browser controls — just the site.

## What's included

- `RJRHub.xcodeproj` — ready-to-open Xcode project
- `RJRHub/RJRHubApp.swift` — app entry point (hides status bar, full screen)
- `RJRHub/ContentView.swift` — hosts the web view, edge-to-edge
- `RJRHub/WebView.swift` — the `WKWebView` wrapper that does the real work:
  - Loads only `https://rafsanjanirupok.com/`
  - Uses `WKWebsiteDataStore.default()`, which is **disk-backed**, so
    cookies, login state, and `localStorage` persist between app launches
    (this is your "save sessions")
  - Bumps `URLCache` to 250 MB on disk so images/CSS/JS the site sends are
    reused on the next open instead of re-downloaded (this is your "save
    web files locally for faster opening")
  - If there's no internet connection when the app opens, it automatically
    falls back to the last cached copy of the page instead of showing a
    blank error screen
  - Any link to a different domain (e.g. a payment gateway or social
    share link) opens in Safari instead of inside the app, since this is
    meant to be a single-purpose viewer, not a general browser
- `RJRHub/Info.plist` — configured for full screen (hidden status bar,
  no launch screen delay)
- `RJRHub/Assets.xcassets/AppIcon.appiconset` — your logo, already
  resized into every icon size iOS needs (20pt–1024pt, all scales)

## How to open and run it

1. Unzip this folder.
2. Double-click `RJRHub.xcodeproj` to open it in Xcode (15 or newer).
3. Select your iPhone (or a simulator) as the run destination.
4. In the project settings (RJRHub target → **Signing & Capabilities**),
   set your own Apple Developer **Team** so Xcode can code-sign the app.
   You can leave the Bundle Identifier as `com.rafsanjanirupok.rjrhub`,
   or change it to something under your own developer account/domain.
5. Press **Run** (⌘R). The app launches straight into the website,
   full screen.

## Installing on your own iPhone without the App Store

- With a free Apple ID: plug your iPhone into your Mac, select it as the
  run destination in Xcode, and press Run. The app installs directly.
  Free accounts require re-installing every 7 days; a paid Apple
  Developer account ($99/yr) removes that limit and lets you distribute
  via TestFlight or the App Store.

## Notes on "saving sessions" and "saving web files locally"

iOS apps aren't allowed to just download and store an entire website's
files ahead of time the way a native offline-first app would — but what
this app does is the standard, App Store–safe way to get the same
result:

- **Sessions**: cookies and `localStorage` are stored on-device by
  `WKWebsiteDataStore` automatically and persist across launches, so if
  the site keeps you logged in via a cookie, you'll stay logged in.
- **Faster loading**: `URLCache` keeps a local copy of static resources
  (images, CSS, JS, fonts) the site serves, so return visits pull most
  assets from disk instead of the network, as long as the site's own
  cache headers allow it.

If you later want a true "available offline" experience (viewing pages
even with zero prior load), that requires either a Service Worker on the
website side (works if the site is a PWA) or building a custom offline
cache of specific pages — let me know if you'd like that added.

## Customizing

- To change the target URL, edit `WebView.siteURL` in `WebView.swift`.
- To change the app name shown under the icon, edit
  `CFBundleDisplayName` in `Info.plist`.
- To regenerate the icon from a new image, drop a 1024×1024 PNG in place
  of the files inside `Assets.xcassets/AppIcon.appiconset/` (same
  filenames), or ask me to regenerate the set from a new source image.
