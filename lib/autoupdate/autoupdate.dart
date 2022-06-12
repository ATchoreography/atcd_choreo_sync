import 'dart:convert';

import 'package:atcd_choreo_sync/version.dart' as app_version;
import 'package:http/http.dart' as http;

import '_web.dart' if (dart.library.io) '_native.dart';

export '_web.dart' if (dart.library.io) '_native.dart';

final Uri _releaseInfoUrl =
    Uri.parse("https://github.com/ATchoreography/atcd_choreo_sync/releases/latest/download/release_info.json");

Future<UpdateAction?> checkUpdatesAndGetAction() async {
  print("Performing update check");
  final resp = await http.get(_releaseInfoUrl);

  if (resp.statusCode != 200) {
    print("Update check failed: ${resp.statusCode}\n${resp.body}");
    return null;
  }

  final releaseInfo = json.decode(resp.body);
  final int versionCode = releaseInfo["versionCode"];

  if (versionCode <= app_version.versionCode) {
    print("Running the latest version");
    return null;
  }

  return UpdateAction(releaseInfo);
}
