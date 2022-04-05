# ATCD Choreography Sync

[![License](https://img.shields.io/badge/license-MPL--2.0-green)](https://github.com/Depau/ATCD-Choreography-Sync/blob/main/LICENSE) [![Quest/Android build](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/android_build_debug.yml/badge.svg)](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/android_build_debug.yml) [![Windows build](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/windows_build.yml/badge.svg)](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/windows_build.yml) [![Linux build](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/linux_build.yml/badge.svg)](https://github.com/Depau/ATCD-Choreography-Sync/actions/workflows/linux_build.yml)

Simple app for both Android (Oculus Quest native) and Windows (PCVR) to sync [Audio Trip](http://audiotripvr.com/) songs from
the [Audio Trip Choreography Discord](https://atcd.club).

## Building

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
