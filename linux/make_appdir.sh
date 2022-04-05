#!/bin/bash

##########################
# RUN IN PROJECT ROOT!!! #
##########################

# Clear old AppDir
rm -rf AppDir || true

# Copy build to AppDir
cp -r build/linux/x64/release/bundle AppDir
cp $(ldd AppDir/atcd_choreo_sync | grep sqlite3 | grep -o '/.*.so.0') AppDir/lib/
strip AppDir/atcd_choreo_sync

# Set up desktop files
mkdir -p AppDir/usr/share/applications
cp linux/atcd_choreo_sync.desktop AppDir/gay.depau.atcd_choreo_sync.desktop
cp linux/atcd_choreo_sync.desktop AppDir/usr/share/applications/gay.depau.atcd_choreo_sync.desktop

# Set up main icon
cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png AppDir/atcd_choreo_sync.png

# Set up hicolor icon theme icons
mkdir -p AppDir/usr/share/icons/hicolor/1024x1024/apps/
cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png AppDir/usr/share/icons/hicolor/1024x1024/apps/atcd_choreo_sync.png
mkdir -p AppDir/usr/share/icons/hicolor/128x128/apps/
cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png AppDir/usr/share/icons/hicolor/128x128/apps/atcd_choreo_sync.png
mkdir -p AppDir/usr/share/icons/hicolor/16x16/apps/
cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png AppDir/usr/share/icons/hicolor/16x16/apps/atcd_choreo_sync.png
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps/
cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png AppDir/usr/share/icons/hicolor/256x256/apps/atcd_choreo_sync.png
mkdir -p AppDir/usr/share/icons/hicolor/32x32/apps/
cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png AppDir/usr/share/icons/hicolor/32x32/apps/atcd_choreo_sync.png
mkdir -p AppDir/usr/share/icons/hicolor/512x512/apps/
cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png AppDir/usr/share/icons/hicolor/512x512/apps/atcd_choreo_sync.png
mkdir -p AppDir/usr/share/icons/hicolor/64x64/apps/
cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png AppDir/usr/share/icons/hicolor/64x64/apps/atcd_choreo_sync.png

# Swap AppRun binary with custom script
cp linux/AppRun AppDir/AppRun
chmod +x AppDir/AppRun
