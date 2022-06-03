Future<bool> is7zipAvailable() async {
  return false;
}

Future<List<String>> extract7zip(
    String outputDir,
    String archivePath,
    ) async {
  throw UnsupportedError("Can't extract 7-zip in browsers");
}
