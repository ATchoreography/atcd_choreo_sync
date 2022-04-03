# ATCD Choreography Sync

[![License](https://img.shields.io/badge/license-MPL--2.0-green)](https://github.com/Depau/ATCD-Choreography-Sync/blob/main/LICENSE) [![Quest/Android build](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/android_build_debug.yml/badge.svg)](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/android_build_debug.yml) [![Windows build](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/windows_build.yml/badge.svg)](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/windows_build.yml)

Simple app for both Android (Oculus Quest native) and Windows (PCVR) to sync Audio Trip songs from
the Audio Trip Choreography Discord.

## Building

On all platforms, fetch the dependencies first:

```bash
cd atcd_choreo_sync
flutter pub get
`````

### Quest / Android

```bash
flutter build apk --no-obfuscate
```

### Linux

```bash
flutter build linux
# Run with:
./build/linux/x64/release/bundle/atcd_choreo_sync
```

### Windows

Must be run on Windows, requires additional setup.

```bash
flutter build windows
```

## License

Mozilla Public License v2.0
