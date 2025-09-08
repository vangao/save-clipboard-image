# Save Clipboard-Image — Finder Toolbar Tool

A macOS helper that saves the current clipboard image into the folder shown by the front Finder window (falls back to Desktop) and gives visual feedback. Designed to be added as a Finder toolbar button.

## Quick Start (Prebuilt App)
- Download: Get the latest from Releases: https://github.com/vangao/save-clipboard-image/releases/latest (download `Save Image.app.zip`).
- Alternatively: `git clone` this repo and use the bundled `Save Image.app`.
- Install: Unzip if needed, then drag `Save Image.app` to `~/Applications`.
- First launch: Because the app isn’t signed/notarized, macOS may warn that it’s from an unidentified developer.
  - Easiest: Right‑click `Save Image.app` → `Open` → `Open`.
  - Advanced: Remove quarantine with `xattr -dr com.apple.quarantine "~/Applications/Save Image.app"`.
- Add to toolbar: See “Install & Add To Toolbar” below.
- Use: Follow the steps in “Use” below.

## What’s Here
- `src/main.swift`: Swift source that saves the clipboard image.
- `build.sh`: Builds the self-contained `Save Image.app` bundle.
- `icon.png` / `icon.icns`: Optional app icon used during build.

## Build
- Prereqs: Xcode Command Line Tools installed (`xcode-select --install`).
- Build the app: `./build.sh`
- Result: `Save Image.app` is created in this folder.

## Install & Add To Toolbar
- Move `Save Image.app` to `~/Applications` (recommended).
- Open `~/Applications` in Finder.
- Hold `Command` and drag `Save Image.app` into the Finder toolbar.
- If dragging is blocked: Finder → View → Customize Toolbar…, then drag it in.

## Use
1. Put an image on the clipboard.
2. Open a Finder window focused on your target folder (avoid Recents/Smart folders).
3. Click the toolbar button. A PNG is created as `Clipboard Shot YYYY-MM-DD at HH.MM.SS.png`.

## Permissions
- Automation: On first run, macOS may ask to allow the app to control Finder. Approve it.
- Manage later: System Settings → Privacy & Security → Automation.

## Customize
- Icon: Place `icon.icns` or `icon.png` (1024×1024) next to `build.sh`, then re-run `./build.sh`.

## Troubleshooting
- No image saved: Ensure an image is on the clipboard; the app will notify if none is found.
- Wrong folder: Make sure the front Finder window is a real folder (not Recents/Smart folders).
- No notification: Notifications use AppleScript `display notification`; check Focus/Do Not Disturb.
- Unidentified developer warning: Right‑click `Save Image.app` → `Open` (or run `xattr -dr com.apple.quarantine "~/Applications/Save Image.app"`).

## Uninstall
- Remove from toolbar via Finder → View → Customize Toolbar…
- Delete `~/Applications/Save Image.app` (or wherever you placed it).
