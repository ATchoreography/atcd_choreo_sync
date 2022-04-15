import 'package:pigeon/pigeon.dart';

/// This file defines the interface for talking to Java code
/// Regenerate with:
/// flutter pub run pigeon \
///   --input pigeons/apkinstaller.dart \
///   --dart_out lib/apkinstaller.dart \
///   --java_out android/app/src/main/java/club/atcd/choreo_sync/apkinstaller/APKInstallerPigeon.java \
///   --java_package club.atcd.choreo_sync.apkinstaller

@HostApi
abstract class APKInstallerAndroid {
  bool hasPermission();
  void launchPermissionsSettingsPage();
  void installApk(String path);
}