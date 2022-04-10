import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'version.dart' as appVersion;

final Uri _releaseInfoUrl =
    Uri.parse("https://github.com/Depau/atcd_choreo_sync/releases/latest/download/release_info.json");

class UpdateAction {
  final Map<String, dynamic> releaseInfo;

  UpdateAction(this.releaseInfo);

  String get version {
    return releaseInfo["versionName"];
  }

  String get name {
    if (Platform.isAndroid) {
      return "Install";
    } else {
      return "Download…";
    }
  }

  Future perform(BuildContext context) async {
    if (false /*Platform.isAndroid*/) {
      Directory destDir = await getExternalStorageDirectory() ?? Directory("/sdcard/Download");
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }
      String destPath = join(destDir.path, "atcd-sync-update.apk");

      // Show non-dismissible dialog
      try {
        unawaited(showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext ctx) => AlertDialog(
                  title: const Text("Downloading update…"),
                  content: Row(children: [
                    Container(
                        child: const CircularProgressIndicator(value: null),
                        width: 96,
                        height: 96,
                        padding: const EdgeInsets.all(24)),
                    const Expanded(child: Text("This may take up to a minute")),
                  ]),
                )));

        final downloader = Dio();
        await downloader.download(releaseInfo["downloads"]["android"], destPath);

        // Launch install intent
        AndroidIntent intent = AndroidIntent(
          action: "action_view",
          data: "file://$destPath",
          type: "application/vnd.android.package-archive",
        );
        await intent.launch();
      } catch (e, st) {
        print(st);
        // Close app
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    } else {
      await launch(releaseInfo["releasePage"]);
    }
  }
}

Future<UpdateAction?> checkUpdatesAndGetAction() async {
  print("Performing update check");
  final resp = await http.get(_releaseInfoUrl);

  if (resp.statusCode != 200) {
    print("Update check failed: ${resp.statusCode}\n${resp.body}");
    return null;
  }

  final releaseInfo = json.decode(resp.body);
  final int versionCode = releaseInfo["versionCode"];

  if (versionCode <= appVersion.versionCode) {
    print("Running the latest version");
    return null;
  }

  return UpdateAction(releaseInfo);
}
