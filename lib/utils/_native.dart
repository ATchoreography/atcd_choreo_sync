import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future wipeDirectory(String path) async {
  Directory dir = Directory(path);
  await dir.delete(recursive: true);
}

Future<bool> isQuest() async {
  if (!Platform.isAndroid) return false;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.brand?.toLowerCase() == "oculus" ||
      androidInfo.manufacturer?.toLowerCase() == "oculus" ||
      // Meta branding isn't used yet but I'm adding it here just in case
      androidInfo.brand?.toLowerCase() == "meta" ||
      androidInfo.manufacturer?.toLowerCase() == "meta";
}
