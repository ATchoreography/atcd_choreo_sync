import 'package:sqflite/sqlite_api.dart';

Future<Database> openDB() async {
  throw UnsupportedError("Not supported on web");
}

Future closeDB() async {
  throw UnsupportedError("Not supported on web");
}

Future wipeDB() async {
  throw UnsupportedError("Not supported on web");
}

Future testDB() async {
  throw UnsupportedError("Not supported on web");
}
