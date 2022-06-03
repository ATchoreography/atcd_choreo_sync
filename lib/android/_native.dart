import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'android_pigeon.dart';

WakelockAndroid? _wakelockPigeonLazy;

WakelockAndroid _getPigeon() {
  assert(Platform.isAndroid);
  _wakelockPigeonLazy ??= WakelockAndroid();
  return _wakelockPigeonLazy!;
}

Future acquireWakelock(int? timeout) async {
  if (!Platform.isAndroid) return;
  return _getPigeon().acquire(timeout);
}

Future releaseWakelock() async {
  if (!Platform.isAndroid) return;
  return _getPigeon().release();
}

Future ensureStoragePermission() async {
  if (!Platform.isAndroid) return;

  while (!(await Permission.storage.request().isGranted)) {
    if (await Permission.storage.shouldShowRequestRationale) {
      await Fluttertoast.showToast(
        msg: "Storage permission is required for the app to run",
        toastLength: Toast.LENGTH_LONG,
      );
    }

    if (await Permission.storage.request().isPermanentlyDenied) {
      await Fluttertoast.showToast(
        msg: "Please enable storage permission manually and reopen app",
        toastLength: Toast.LENGTH_LONG,
      );

      await openAppSettings();

      // Close app
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }
}
