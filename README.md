# ATCD Choreography Sync

[![License](https://img.shields.io/badge/license-MPL--2.0-green)](https://github.com/Depau/ATCD-Choreography-Sync/blob/main/LICENSE) [![Build](https://github.com/Depau/atcd_choreo_sync/actions/workflows/build.yml/badge.svg)](https://github.com/Depau/atcd_choreo_sync/actions/workflows/build.yml)

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
# app will be at: build/linux/x64/release/bundle/atcd_choreo_sync
```

### Windows

Must be run on Windows, requires additional setup.

```bash
flutter build windows
# app will be at: build\windows\runner\Release\
```

### macOS

Must be run on macOS, requires lots of additional setup

```bash
flutter build macos
# app will be at: build/macos/Build/Products/Release/
```

## License

Mozilla Public License v2.0
