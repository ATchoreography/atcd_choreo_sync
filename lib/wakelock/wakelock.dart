import 'dart:io';

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
