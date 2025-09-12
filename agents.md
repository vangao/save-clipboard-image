# Save Clipboard — Finder Toolbar Tool

A macOS helper that saves the current clipboard content into the folder shown by the front Finder window (falls back to Desktop) and gives visual feedback. Designed to be added as a Finder toolbar button. Supports images (PNG), HTML (`.html`), Markdown for other text (`.md`), and Python code (`.py`). Filenames are concise and auto-numbered per type (e.g., `Clip-Img-1.png`).

## What’s Here
- `src/main.swift`: Swift source for saving image, HTML, Markdown, and Python.
- `build.sh`: Builds the self-contained `Save Clipboard.app` bundle (renameable with flags).
- `icon.png` / `icon.icns`: Optional app icon used during build.

## Build
- Prereqs: Xcode Command Line Tools installed (`xcode-select --install`).
- Build the app: `./build.sh` → produces `Save Clipboard.app`.
- Customize name/bundle id: `./build.sh --name "Save Clipboard" --id local.save-clipboard`.

## Install & Add To Toolbar
- Move `Save Clipboard.app` to `~/Applications` (recommended).
- Open `~/Applications` in Finder.
- Hold `Command` and drag `Save Clipboard.app` into the Finder toolbar.
- If dragging is blocked: Finder → View → Customize Toolbar…, then drag it in.

## Use
1. Put an image or text on the clipboard.
2. Open a Finder window focused on your target folder (avoid Recents/Smart folders).
3. Click the toolbar button. Saves with concise names:
   - Image → `Clip-Img-N.png`
   - Python → `Clip-Py-N.py`
   - HTML → `Clip-Html-N.html`
   - Other text → `Clip-Md-N.md`

## Permissions
- Automation: On first run, macOS may ask to allow the app to control Finder. Approve it.
- Manage later: System Settings → Privacy & Security → Automation.

## Customize
- Icon: Place `icon.icns` or `icon.png` (1024×1024) next to `build.sh`, then re-run `./build.sh`.

## Troubleshooting
- No file saved: Ensure image or text is on the clipboard; the app will notify if none is found.
- Wrong folder: Make sure the front Finder window is a real folder (not Recents/Smart folders).
- No notification: Notifications use AppleScript `display notification`; check Focus/Do Not Disturb.

## Uninstall
- Remove from toolbar via Finder → View → Customize Toolbar…
- Delete `~/Applications/Save Clipboard.app` (or wherever you placed it).
