#!/bin/bash

rm -rf AppDir || true
cp -r atcd_choreo_sync/build/linux/x64/release/bundle AppDir
mkdir -p AppDir/usr/share/applications
cp atcd_choreo_sync/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png AppDir/atcd_choreo_sync.png
cp appimage/atcd_choreo_sync.desktop AppDir/gay.depau.atcd_choreo_sync.desktop
cp appimage/atcd_choreo_sync.desktop AppDir/usr/share/applications/gay.depau.atcd_choreo_sync.desktop
mkdir -p AppDir/usr/share/icons/hicolor/192x192/apps/
mkdir -p AppDir/usr/share/icons/hicolor/96x96/apps/
mkdir -p AppDir/usr/share/icons/hicolor/48x48/apps/
cp atcd_choreo_sync/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png AppDir/usr/share/icons/hicolor/192x192/apps/atcd_choreo_sync.png
cp atcd_choreo_sync/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png AppDir/usr/share/icons/hicolor/96x96/apps/atcd_choreo_sync.png
cp atcd_choreo_sync/android/app/src/main/res/mipmap-mdpi/ic_launcher.png AppDir/usr/share/icons/hicolor/48x48/apps/atcd_choreo_sync.png
cp appimage/AppRun AppDir/AppRun
chmod +x AppDir/AppRun
