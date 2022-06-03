import 'dart:io';

import 'package:atcd_choreo_sync/7zip/with_executable.dart';

import 'android_pigeon.dart';

Future<bool> is7zipAvailable() async {
  if (Platform.isAndroid) {
    return true;
  }
  return await find7zExecutable() != null;
}

Future<List<String>> extract7zip(
    String outputDir,
    String archivePath,
    ) async {
  if (Platform.isAndroid) {
    final extractor = P7ZipExtractorAndroid();
    List<String> result = [];
    for (String? file in await extractor.extractArchive(archivePath, outputDir)) {
      result.add(file!);
    }
    return result;
  }

  String z7exe = (await find7zExecutable())!;

  List<String> fileList = (await getArchiveFileListWithExe(z7exe, archivePath).toSet()).toList();
  await extractArchiveWithExe(z7exe, archivePath, outputDir);

  return fileList;
}
