import 'dart:ffi';
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';

const String audioTripPackageName = "com.KinemotikStudios.AudioTripQuest";

// Reference:
// - https://docs.unity3d.com/ScriptReference/Application-persistentDataPath.html
// - https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath
String _windowsChoreoPath() {
  final folderID = GUIDFromString(FOLDERID_LocalAppDataLow);
  Pointer<PWSTR> ppszPath = calloc<PWSTR>();
  try {
    var result = SHGetKnownFolderPath(folderID, 0, 0, ppszPath);
    if (result != S_OK) throw WindowsException(result);

    try {
      var dartPath = ppszPath.value.toDartString();
      return join(dartPath, "Kinemotik Studios", "Audio Trip", "Songs", "ATCD Sync");
    } finally {
      CoTaskMemFree(ppszPath.value);
    }
  } finally {
    calloc.free(ppszPath);
  }
}

Future<String> getChoreosPath() async {
  if (Platform.isLinux || Platform.isMacOS) {
    return join(Platform.environment["HOME"]!, "ATCD Choreo Sync");
  } else if (Platform.isWindows) {
    return _windowsChoreoPath();
  } else if (Platform.isAndroid) {
    Directory filesDir = (await getExternalStorageDirectory())!;
    List<String> splitFilesPath = split(filesDir.path);
    int androidIndex = splitFilesPath.indexOf("Android");
    if (androidIndex < 0) {
      print("Unable to ask nicely for the sdcard location, going with a guess");
      return "/sdcard/Android/data/com.KinemotikStudios.AudioTripQuest/files/Songs/ATCD Sync";
    }
    String androidPath = joinAll(splitFilesPath.sublist(0, androidIndex + 1));
    return join(androidPath, "data", "com.KinemotikStudios.AudioTripQuest", "files", "Songs", "ATCD Sync");
  }
  throw UnsupportedError("The current platform is not supported!");
}

bool? _atInstalledLazyVal;

Future<bool> isAudioTripInstalled() async {
  if (Platform.isAndroid) {
    _atInstalledLazyVal ??= await DeviceApps.isAppInstalled(audioTripPackageName);
    return _atInstalledLazyVal!;
  }
  return false;
}

Future<void> launchAudioTrip() async {
  if (Platform.isAndroid) {
    await DeviceApps.openApp(audioTripPackageName);
  }
}
