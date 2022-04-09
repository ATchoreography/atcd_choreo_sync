import 'package:pigeon/pigeon.dart';

/// This file defines the interface for talking to Java code
/// Regenerate with:
/// flutter pub run pigeon \
///   --input pigeons/7zip_extractor.dart \
///   --dart_out lib/7zip/android_pigeon.dart \
///   --java_out android/app/src/main/java/club/atcd/choreo_sync/p7zip/P7ZipExtractorPigeon.java \
///   --java_package club.atcd.choreo_sync.p7zip

@HostApi
abstract class P7ZipExtractorAndroid {
  List<String> extractArchive(String archivePath, String outputDir);
}