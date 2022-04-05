import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import '../settings.dart';

Stream<String> _get7zSearchPaths() async* {
  final env = Platform.environment;
  final settingsPath = await Settings().z7installPath;
  final exeDir = dirname(Platform.resolvedExecutable);

  // All platforms: add
  // - User-configured location
  // - Current application directory
  // - Current application library directory
  if (settingsPath != null) {
    yield settingsPath;
  }
  yield exeDir;
  yield join(exeDir, "lib");

  if (Platform.isLinux || Platform.isMacOS) {
    // Linux: add $PATH
    if (env.containsKey("PATH")) {
      for (String item in env["PATH"]!.split(":")) {
        yield item;
      }
    }
  } else if (Platform.isWindows) {
    // Windows: add known 7-Zip installation directories
    for (String envVar in ["ProgramFiles", "ProgramFiles(x86)", "ProgramW6432"]) {
      if (env.containsKey(envVar)) {
        yield join(env[envVar]!, "7-Zip");
      }
    }
    // Windows: add %PATH%
    if (env.containsKey("PATH")) {
      for (String item in env["PATH"]!.split(";")) {
        yield item;
      }
    }
  }
}

List<String> _get7zExecutableNames() {
  var result = ["7zzs", "7zz", "7z", "7za", "7zr"];
  if (Platform.isWindows) {
    return result.map((e) => e + ".exe").toList();
  }
  return result;
}

Future<String?> find7zExecutable() async {
  final exeNames = _get7zExecutableNames();

  await for (String path in _get7zSearchPaths()) {
    final dir = Directory(path);
    if (!await dir.exists()) continue;

    for (String exeName in exeNames) {
      final exe = File(join(path, exeName));
      if (await exe.exists()) {
        print("Found 7zip executable: ${exe.path}");
        return exe.path;
      }
    }
  }
  return null;
}

/*
    The output looks like this:


    7-Zip [64] 17.04 : Copyright (c) 1999-2021 Igor Pavlov : 2017-08-28
    p7zip Version 17.04 (locale=en_US.UTF-8,Utf16=on,HugeFiles=on,64 bits,12 CPUs x64)

    Scanning the drive for archives:
    1 file, 994295 bytes (971 KiB)

    Listing archive: /home/depau/Downloads/7z2107-extra.7z

    --
    Path = /home/depau/Downloads/7z2107-extra.7z
    Type = 7z
    Physical Size = 994295
    Headers Size = 535
    Method = LZMA:22 BCJ2
    Solid = +
    Blocks = 2

    ----------
    Path = Far/7-ZipEng.hlf
    Size = 2366
    Packed Size = 9256
    Modified = 2021-12-27 11:46:04
    Attributes = A
    CRC = FCD899D8
    Encrypted = -
    Method = LZMA:22
    Block = 0

    Path = Far/7-ZipEng.lng
    Size = 2981
    Packed Size =
    Modified = 2017-05-05 11:06:34
    Attributes = A
    CRC = 8254F21C
    Encrypted = -
    Method = LZMA:22
    Block = 0

    ...
 */
Stream<String> getArchiveFileListWithExe(String z7exe, String archivePath) async* {
  final args = ["l", archivePath, "-slt", "-bd"];
  var process = await Process.start(z7exe, args);

  bool headerStripped = false;
  await for (String line in process.stdout.transform(utf8.decoder).transform(const LineSplitter())) {
    line = line.trim();
    if (!headerStripped) {
      if (line == "----------") {
        headerStripped = true;
      }
      continue;
    }
    if (line.startsWith("Path = ")) {
      yield line.replaceFirst("Path = ", "");
    }
  }
  int exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw ProcessException(z7exe, args, "Called process exited with non-zero status code $exitCode", exitCode);
  }
}

Future extractArchiveWithExe(String z7exe, String archivePath, String outputDir) async {
  final args = ["x", archivePath, "-y", "-bd", "-o" + outputDir];
  var process = await Process.run(z7exe, args);
  if (process.exitCode != 0) {
    throw ProcessException(
        z7exe, args, "Called process exited with non-zero status code ${process.exitCode}", process.exitCode);
  }
}
