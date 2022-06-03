import 'dart:io';

import 'package:atcd_choreo_sync/platform/_common.dart';

TargetOS get targetOS {
  if (Platform.isWindows) return TargetOS.windows;
  if (Platform.isLinux) return TargetOS.linux;
  if (Platform.isAndroid) return TargetOS.android;
  if (Platform.isMacOS) return TargetOS.macos;
  throw UnsupportedError("Unsupported native platform");
}

void assertWeb() {
  throw UnsupportedError("This code was expected to run on web only, but it ran on a native platform");
}

void assertNative() {}
