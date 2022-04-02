import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';

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
  if (Platform.isLinux) {
    print("Warning! AT path discovery for Linux is not implemented! "
        "This likely depends on the installation method, we need to find the wineprefix");
    return "/tmp/AudioTripSongs/";
  } else if (Platform.isWindows) {
    return _windowsChoreoPath();
  } else if (Platform.isAndroid) {
    Directory sdcard = (await getExternalStorageDirectory())!;
    return join(sdcard.path, "Android", "data", "com.KinemotikStudios.AudioTripQuest", "files", "Songs", "ATCD Sync");
  }
  throw UnsupportedError("The current platform is not supported!");
}
