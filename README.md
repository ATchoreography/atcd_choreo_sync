# ATCD Choreography Sync

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