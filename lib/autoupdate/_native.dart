import 'dart:async';
import 'dart:io';

import 'package:atcd_choreo_sync/autoupdate/update_action_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'apkinstaller.dart';

class UpdateAction extends UpdateActionBase {
  UpdateAction(Map<String, dynamic> releaseInfo) : super(releaseInfo);

  @override
  String get name {
    if (Platform.isAndroid) {
      return "Install";
    } else {
      return "Download…";
    }
  }

  Future _showApkPermissionsDialog(BuildContext context) async {
    var installer = APKInstallerAndroid();
    if (await installer.hasPermission()) return;

    await showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text("Permissions required"),
        content:
            const Text("Additional permissions are required to install app updates. Please grant them in Settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
              onPressed: () async {
                await installer.launchPermissionsSettingsPage();
                Navigator.of(context).pop();
              },
              child: const Text('Open Settings…')),
        ],
      ),
    );
  }

  @override
  Future<bool> ensurePrerequisites(BuildContext context) async {
    if (!Platform.isAndroid) {
      return true;
    }

    var installer = APKInstallerAndroid();
    if (await installer.hasPermission()) {
      return true;
    }

    await _showApkPermissionsDialog(context);
    return false;
  }

  @override
  Future perform(BuildContext context) async {
    if (Platform.isAndroid) {
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

        var installer = APKInstallerAndroid();
        await installer.installApk(destPath);

        // Close dialog
        Navigator.of(context).pop();
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
