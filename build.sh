#!/bin/bash

# Configuration
APP_NAME="Todo"
BINARY_NAME="todo"
BUNDLE_ID="com.skhahehe.todo"
APP_BUNDLE="${APP_NAME}.app"
DMG_NAME="${APP_NAME}.dmg"

echo "🔨 Building ${APP_NAME}..."

# 1. Compile the Swift files
swiftc -o "${BINARY_NAME}" ContentView.swift todoApp.swift -framework SwiftUI -framework AppKit

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed."
    exit 1
fi

# 2. Create the app bundle structure if it doesn't exist
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# 3. Move the binary into the bundle
mv "${BINARY_NAME}" "${APP_BUNDLE}/Contents/MacOS/"

# 4. Copy Info.plist (assuming it exists in the current dir or temp create it)
if [ -f "todo.app/Contents/Info.plist" ]; then
    cp "todo.app/Contents/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"
else
    cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${BINARY_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>icon</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
</dict>
</plist>
EOF
fi

# 5. Copy icon if it exists
if [ -f "todo.app/Contents/Resources/icon.icns" ]; then
    cp "todo.app/Contents/Resources/icon.icns" "${APP_BUNDLE}/Contents/Resources/"
fi

echo "✅ App bundle created: ${APP_BUNDLE}"

# 6. Create DMG
echo "📦 Packaging into DMG..."
if [ -f "${DMG_NAME}" ]; then
    rm "${DMG_NAME}"
fi

hdiutil create -volname "${APP_NAME}" -srcfolder "${APP_BUNDLE}" -ov -format UDZO "${DMG_NAME}"

echo "✅ DMG created: ${DMG_NAME}"
