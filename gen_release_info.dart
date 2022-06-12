import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

main(List<String> args) {
  if (args.length < 2) {
    print("Usage: dart run ./gen_release_info.dart [pubspec.yaml] [release_info.json]");
    exit(1);
  }
  final pubspecFile = File(args[0]);
  if (!pubspecFile.existsSync()) {
    print("No such file or directory: ${args[0]}");
    exit(1);
  }
  YamlMap pubspec = loadYaml(pubspecFile.readAsStringSync());
  List<String> version = pubspec["version"].split("+");

  String versionName = version[0];
  int versionCode = int.parse(version[1]);

  final urlBase = "https://github.com/ATchoreography/atcd_choreo_sync/releases/download/v$versionName";
  Map<String, dynamic> releaseInfo = {
    "versionName": versionName,
    "versionCode": versionCode,
    "releasePage": "https://github.com/ATchoreography/atcd_choreo_sync/releases/tag/v$versionName",
    "downloads": <String, String>{
      "android": "$urlBase/atcd_choreo_sync-OculusQuest-android-v$versionName.apk",
      "windows": "$urlBase/atcd_choreo_sync-windows-v$versionName.zip",
      "macos": "$urlBase/atcd_choreo_sync-macOS-v$versionName.zip",
      "linux_appimage": "$urlBase/atcd_choreo_sync-gnulinux-v$versionName.AppImage",
    }
  };

  final jDoc = const JsonEncoder.withIndent("  ").convert(releaseInfo);

  if (args[1] == "-") {
    print(jDoc);
  } else {
    final outFile = File(args[1]);
    outFile.writeAsString(jDoc);
  }
}
