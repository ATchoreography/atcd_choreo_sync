import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:atcd_choreo_sync/7zip/7zip.dart';
import 'package:atcd_choreo_sync/platform/platform.dart';
import 'package:atcd_choreo_sync/repositories.dart';
import 'package:atcd_choreo_sync/settings.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

import 'model.dart';

Future<Map<int, DownloadStatus>> genDownloadStatusMap(List<Choreo> choreos, Database? db) async {
  Map<int, DownloadStatus> result = {};

  if (db == null) {
    assertWeb();

    for (Choreo choreo in choreos) {
      result[choreo.id!] = DownloadStatus.missing;
    }
    return result;
  }

  assertNative();

  var filerepo = ChoreoFileRepository(db);
  final choreoPath = await Settings().ensureChoreosPath;

  for (Choreo choreo in choreos) {
    DownloadStatus status = DownloadStatus.missing;

    List<ChoreoFile> files = await filerepo.byChoreo(choreo);
    if (files.isNotEmpty) {
      status = DownloadStatus.present;
      for (ChoreoFile file in files) {
        final dartFile = File(join(choreoPath, file.file));
        if (!await dartFile.exists()) {
          status = DownloadStatus.missing;
          break;
        }
      }
    }

    result[choreo.id!] = status;
  }

  return result;
}

Future _extractZipIsolate(Tuple3<SendPort, String, String> params) async {
  SendPort sendPort = params.item1;
  String destDir = params.item2;
  String archivePath = params.item3;

  List<String> archiveFiles = [];

  final inputStream = InputFileStream(archivePath);
  final archive = ZipDecoder().decodeBuffer(inputStream);

  for (var file in archive.files) {
    if (file.isFile) {
      final fname = basename(file.name);
      final outputStream = OutputFileStream(join(destDir, fname));
      file.writeContent(outputStream);
      await outputStream.close();
      archiveFiles.add(fname);
    }
  }
  await inputStream.close();
  Isolate.exit(sendPort, archiveFiles);
}

Future<List<String>> extractZip(String destDir, String archivePath) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_extractZipIsolate, Tuple3(receivePort.sendPort, destDir, archivePath));
  return await receivePort.first as List<String>;
}

Future<List<String>> downloadChoreo(Choreo choreo) async {
  final choreoPath = await Settings().ensureChoreosPath;
  Uri uri = Uri.parse(choreo.url);
  String filename = uri.pathSegments.last;
  bool isArchive = !filename.endsWith(".ats");

  String downloadPath;

  if (isArchive) {
    downloadPath = join((await getTemporaryDirectory()).path, "${choreo.id!}-$filename");
  } else {
    downloadPath = join(choreoPath, filename);
  }

  final downloader = Dio(); // lol
  await downloader.download(choreo.url, downloadPath);

  if (isArchive) {
    try {
      if (downloadPath.toLowerCase().endsWith(".zip")) {
        return await extractZip(choreoPath, downloadPath);
      } else {
        return await extract7zip(choreoPath, downloadPath);
      }
    } finally {
      await File(downloadPath).delete();
    }
  } else {
    return [filename];
  }
}

Future deleteChoreo(Choreo choreo, Database db) async {
  var filerepo = ChoreoFileRepository(db);
  final choreoPath = await Settings().ensureChoreosPath;

  List<ChoreoFile> files = await filerepo.byChoreo(choreo);
  if (files.isNotEmpty) {
    for (ChoreoFile file in files) {
      final dartFile = File(join(choreoPath, file.file));
      if (await dartFile.exists()) {
        await dartFile.delete();
      }
    }
  }
}
