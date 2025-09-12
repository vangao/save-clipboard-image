# Save Clipboard — Finder Toolbar Tool

A macOS helper that saves the current clipboard content into the folder shown by the front Finder window (falls back to Desktop) and gives visual feedback. Designed to be added as a Finder toolbar button. It supports images (PNG), HTML saved as `.html`, other text saved as Markdown (`.md`), and Python code (`.py`).

## Quick Start (Prebuilt App)
- Direct download: Anyone can use the prebuilt `Save Clipboard.app` on macOS (10.13+) — no build or Xcode required.
- Download: Get the latest from Releases: https://github.com/vangao/save-clipboard-image/releases/latest (download `Save Clipboard.app.zip`).
- Alternatively: `git clone` this repo and use the bundled `Save Clipboard.app`.
- Install: Unzip if needed, then drag `Save Clipboard.app` to `~/Applications`.
- First launch: Because the app isn’t signed/notarized, macOS may warn that it’s from an unidentified developer.
  - Easiest: Right‑click `Save Clipboard.app` → `Open` → `Open`.
  - Advanced: Remove quarantine with `xattr -dr com.apple.quarantine "~/Applications/Save Clipboard.app"`.
- Add to toolbar: See “Install & Add To Toolbar” below.
- Use: Follow the steps in “Use” below.

## What’s Here
- `src/main.swift`: Swift source for saving image, HTML, Markdown, and Python.
- `build.sh`: Builds the self-contained `Save Clipboard.app` bundle (renameable).
- `icon.png` / `icon.icns`: Optional app icon used during build.

## Build
- Prereqs: Xcode Command Line Tools installed (`xcode-select --install`).
- Build the app: `./build.sh` → produces `Save Clipboard.app`.
- Customize name/bundle id:
  - Example: `./build.sh --name "Save Clipboard" --id local.save-clipboard`
  - Result: `Save Clipboard.app` with the chosen bundle id.

## Install & Add To Toolbar
- Move `Save Clipboard.app` to `~/Applications` (recommended).
- Open `~/Applications` in Finder.
- Hold `Command` and drag `Save Clipboard.app` into the Finder toolbar.
- If dragging is blocked: Finder → View → Customize Toolbar…, then drag it in.

## Use
1. Put an image or text on the clipboard.
2. Open a Finder window focused on your target folder (avoid Recents/Smart folders).
3. Click the toolbar button. Saves based on clipboard type with concise, numbered names:
   - Image → `Clip-Img-1.png`, `Clip-Img-2.png`, …
   - Python → `Clip-Py-1.py`, `Clip-Py-2.py`, …
   - HTML → `Clip-Html-1.html`, …
   - Text (plain/RTF) → `Clip-Md-1.md`, …

## Permissions
- Automation: On first run, macOS may ask to allow the app to control Finder. Approve it.
- Manage later: System Settings → Privacy & Security → Automation.

## Customize
- Icon: Place `icon.icns` or `icon.png` (1024×1024) next to `build.sh`, then re-run `./build.sh`.

## Troubleshooting
- No file saved: Ensure image or text is on the clipboard; the app will notify if none is found.
- Wrong folder: Make sure the front Finder window is a real folder (not Recents/Smart folders).
- No notification: Notifications use AppleScript `display notification`; check Focus/Do Not Disturb.
- Unidentified developer warning: Right‑click `Save Clipboard.app` → `Open` (or run `xattr -dr com.apple.quarantine "~/Applications/Save Clipboard.app"`).

## Uninstall
- Remove from toolbar via Finder → View → Customize Toolbar…
- Delete `~/Applications/Save Clipboard.app` (or wherever you placed it).
