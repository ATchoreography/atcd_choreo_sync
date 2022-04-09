import 'package:pigeon/pigeon.dart';

/// This file defines the interface for talking to Java code
/// Regenerate with:
/// flutter pub run pigeon \
///   --input pigeons/wakelock.dart \
///   --dart_out lib/wakelock/android_pigeon.dart \
///   --java_out android/app/src/main/java/club/atcd/choreo_sync/wakelock/WakelockPigeon.java \
///   --java_package club.atcd.choreo_sync.wakelock

@HostApi
abstract class WakelockAndroid {
  void acquire(int? timeout);
  void release();
}