#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Save Image"
APP_DIR="$(pwd)/${APP_NAME}.app"
MACOS_DIR="${APP_DIR}/Contents/MacOS"
RES_DIR="${APP_DIR}/Contents/Resources"
PLIST="${APP_DIR}/Contents/Info.plist"

echo "Building ${APP_NAME}.app ..."

rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RES_DIR}"

echo "Compiling Swift binary..."
swiftc -O -framework AppKit src/main.swift -o "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "Writing Info.plist..."
cat >"${PLIST}" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Save Image</string>
    <key>CFBundleIdentifier</key>
    <string>local.save-clipboard-image</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Save Image</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>Used to read the front Finder window path to save your clipboard image.</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
PLIST

# Icon handling
if [[ -f "icon.icns" ]]; then
  echo "Adding icon.icns ..."
  cp -f "icon.icns" "${RES_DIR}/AppIcon.icns"
elif [[ -f "icon.png" ]]; then
  echo "Generating .icns from icon.png ..."
  tmpdir=$(mktemp -d)
  iconset="${tmpdir}/AppIcon.iconset"
  mkdir -p "${iconset}"
  # Generate required sizes
  sips -z 16 16   icon.png --out "${iconset}/icon_16x16.png" >/dev/null
  sips -z 32 32   icon.png --out "${iconset}/icon_16x16@2x.png" >/dev/null
  sips -z 32 32   icon.png --out "${iconset}/icon_32x32.png" >/dev/null
  sips -z 64 64   icon.png --out "${iconset}/icon_32x32@2x.png" >/dev/null
  sips -z 128 128 icon.png --out "${iconset}/icon_128x128.png" >/dev/null
  sips -z 256 256 icon.png --out "${iconset}/icon_128x128@2x.png" >/dev/null
  sips -z 256 256 icon.png --out "${iconset}/icon_256x256.png" >/dev/null
  sips -z 512 512 icon.png --out "${iconset}/icon_256x256@2x.png" >/dev/null
  sips -z 512 512 icon.png --out "${iconset}/icon_512x512.png" >/dev/null
  cp icon.png "${iconset}/icon_512x512@2x.png"  # 1024x1024 source assumed
  if iconutil -c icns "${iconset}" -o "${RES_DIR}/AppIcon.icns" 2>/dev/null; then
    echo "Icon generated."
  else
    echo "iconutil not available; skipping icon."
  fi
  rm -rf "${tmpdir}"
else
  echo "No icon provided; using generic app icon."
fi

echo "Done: ${APP_DIR}"

