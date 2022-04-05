import 'dart:convert';

import 'package:atcd_choreo_sync/repositories.dart';
import 'package:atcd_choreo_sync/settings.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'model.dart';

// The best date is a sushi date anyway
String fixFreedomDate(String freedomDate) {
  // From MM/DD/YYYY
  var split = freedomDate.split("/");
  // To YYYY/MM/DD
  return <String>[split[2].padLeft(4, '0'), split[0].padLeft(2, '0'), split[1].padLeft(2, '0')].join("/");
}

Stream<Choreo> fetchChoreos({bool has7zip = false}) async* {
  print("Fetching choreography spreadsheet");
  final Uri _csvUrl = Uri.parse(await Settings().csvUrl);
  var resp = await http.get(_csvUrl);

  // For some reason it can't decode it properly by itself
  var body = utf8.decode(resp.bodyBytes);

  const csvParser = CsvToListConverter(shouldParseNumbers: false);
  final csv = csvParser.bind(() async* {
    yield body;
  }());

  int titleCol = 0;
  int warningsCol = 1;
  int artistsCol = 2;
  int mapperCol = 3;
  int difficultyCol = 4;
  int bpmCol = 5;
  int lengthCol = 6;
  int releasedCol = 7;
  int urlCol = 8;

  bool foundHeader = false;

  await for (List row in csv) {
    if (!foundHeader) {
      if (row[0].toLowerCase().contains("title")) continue;
      foundHeader = true;

      for (int i = 0; i < row.length; i++) {
        var text = row[i].toLowerCase().trim();
        switch (text) {
          case "title":
            titleCol = i;
            break;
          case "artists":
            artistsCol = i;
            break;
          case "mapper":
            mapperCol = i;
            break;
          case "difficulty":
            difficultyCol = i;
            break;
          case "bpm":
            bpmCol = i;
            break;
          case "length":
            lengthCol = i;
            break;
          case "released":
            releasedCol = i;
            break;
          case "get all":
            urlCol = i;
            break;
        }
      }
      continue;
    }

    String url = row[urlCol].trim();
    if (!url.startsWith("https://")) {
      continue;
    }
    if (!has7zip && url.endsWith(".7z")) {
      continue;
    }

    try {
      String title = row[titleCol].toString().trim();
      if (row[warningsCol].toString().trim().isNotEmpty) {
        title += " " + row[warningsCol];
      }

      num? bpm;
      try {
        bpm = num.parse(row[bpmCol]);
      } catch (_) {}

      var choreo = Choreo(
          title: title,
          artists: row[artistsCol],
          mapper: row[mapperCol],
          difficulty: row[difficultyCol],
          bpm: bpm,
          length: row[lengthCol],
          released: fixFreedomDate(row[releasedCol]),
          url: url);
      // print(choreo.toString());

      yield choreo;
    } catch (_) {
      print("Error parsing the following CSV line:");
      for (int i = 0; i < row.length; i++) {
        print("$i: ${row[i]}");
      }
      rethrow;
    }
  }
}

Stream<Choreo> persistToDatabase(Stream<Choreo> choreos, Database db) async* {
  final repo = ChoreoRepository(db);
  await for (Choreo choreo in choreos) {
    yield await repo.insertOrUpdateByUrl(choreo);
  }
}
