# ATCD Choreography Sync

[![License](https://img.shields.io/badge/license-MPL--2.0-green)](https://github.com/Depau/ATCD-Choreography-Sync/blob/main/LICENSE) [![Build](https://github.com/Depau/atcd_choreo_sync/actions/workflows/build.yml/badge.svg)](https://github.com/Depau/atcd_choreo_sync/actions/workflows/build.yml)

Simple app for both Android (Oculus Quest native) and Windows (PCVR) to
sync [Audio Trip](http://audiotripvr.com/) songs from
the [Audio Trip Choreography Discord](https://atcd.club).

<div style="text-align: center;">
  <div style="display: inline-block;">
  [![Get it on SideQuest](./.misc/get_it_on_sidequest.webp)](https://sidequestvr.com/app/7955)<br/>
  For Oculus Quest and Windows
  </div>
  <div style="display: inline-block;">
  [![Get it on GitHub](./.misc/get_it_on_github.webp)](releases/)<br/>
  For all platforms
  </div>
</div>

## Installing the app

Download the latest version of the app for your platform from
the [Releases](https://github.com/Depau/atcd_choreo_sync/releases) page.

### Oculus Quest

### Using SideQuest (easier!)

- Download and set-up [SideQuest](https://sidequestvr.com/setup-howto) on your computer
- Find and install the app: [ATCD Choreography Sync](https://sidequestvr.com/app/7955)

### Manually
- Download the Android APK file
- Drag it on the [SideQuest](https://sidequestvr.com/setup-howto) main window
  or
- Use `adb` to install it: `adb install atcd_choreo_sync-OculusQuest-Android-v*.apk`

The Quest application will automatically install songs to the Audio Trip folder:

```
/sdcard/Android/data/com.KinemotikStudios.AudioTripQuest/files/Songs/ATCD Sync
```

### Windows

- There is no installer
- Just download it double-click `atcd_choreo_sync.exe`

The Windows application will automatically install songs to the Audio Trip folder for PCVR:

```
%USERPROFILE%\AppData\LocalLow\Kinemotik Studios\Audio Trip\Songs\ATCD Sync
```

### macOS

- Extract the zip archive
- Drag and drop the app to `/Applications`, as you normally would

If your precious laptop says that "the app is damaged" you should know it is lying to you. That's
its way of letting you know I refused to pay 100€/year to Apple for them to vouch this application.

Since Apple will never see a cent from me, if you want to run it anyway, you can open up the "
Terminal" app and run the following command:

```bash
xattr -cr "/Applications/ATCD Choreography Sync.app"
```

Then open Finder, go to Applications, **right-click the app, then click open**.

Notice how I specifically did not type *double-click the app*, I typed *right click the app, then
click open*.

If you are a naughty person and you recognize that if I didn't write it twice, you would have
double-clicked on it, you better star this project and follow me on Instagram :)

The macOS application downloads all songs to your home directory. You need to use SideQuest to push
them to your Quest.

```bash
~/ATCD Choreo Sync
```

### GNU/Linux

- Download the AppImage
- Make it executable (i.e. `chmod +x atcd_choreo_sync-gnulinux-v1.0.0.AppImage`)
- Double-click or `./atcd_choreo_sync-gnulinux-v1.0.0.AppImage`

The Linux application downloads all songs to your home directory. You need to use SideQuest to push
them to your Quest.

```bash
~/ATCD Choreo Sync
```

###

## Building the app

- Install Flutter by following the guide for your
  platform: [Flutter - Get started](https://docs.flutter.dev/get-started/install)
- Build the app

```bash
# Android/Quest
flutter build apk
# Output: build/app/outputs/flutter-apk/app-release.apk

# Windows (must be built on Windows)
flutter build windows
# Output: build\windows\runner\Release\

# macOS (must be built on macOS)
# Hint: if you have trouble installing CocoaPods, use brew
flutter build macos
# Output: build/macos/Build/Products/Release/

# Linux (must be built on Linux)
flutter build linux
# Output: build/linux/x64/release/bundle/atcd_choreo_sync

# Linux AppImage, after regular build
./linux/make_appdir.sh
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
ARCH=x86_64 ./appimagetool-x86_64.AppImage AppDir './outputs/atcd_choreo_sync.AppImage'
```

### Android Gradle sync issues

If Gradle fails mysteriously for unknown reasons, it may be because you're missing some Android SDK
platforms. To find out which ones, you can look for `SdkPlatformNotFoundException` in
the `idea.log` (if Gradle sync fails there should be a button to open the log)

```bash
$ grep -r 'com.android.tools.idea.gradle.project.sync.idea.issues.SdkPlatformNotFoundException' \
  ~/.cache/Google/AndroidStudio*/log/idea.log

com.android.tools.idea.gradle.project.sync.idea.issues.SdkPlatformNotFoundException: Module: 'sqlite3_flutter_libs' platform 'android-28' not found.
com.android.tools.idea.gradle.project.sync.idea.issues.SdkPlatformNotFoundException: Module: 'device_apps' platform 'android-30' not found.
```

Install them manually from the SDK manager.

## License

Mozilla Public License v2.0
