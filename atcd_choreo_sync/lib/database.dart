import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mutex/mutex.dart';

bool _dbInited = false;

_initDb() {
  if (_dbInited) {
    return;
  }
  if (Platform.isWindows || Platform.isLinux) {
    // Load sqlite3 dynamic library
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  _dbInited = true;
}

Future<String> _getDBPath() async {
  if (Platform.isAndroid) {
    return getDatabasesPath();
  } else {
    return (await getApplicationSupportDirectory()).path;
  }
}

Future<String> _ensureDBPath() async {
  final String dbPath = await _getDBPath();
  print("Database location: $dbPath");
  await Directory(dbPath).create(recursive: true);
  return dbPath;
}

_onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion == 0 && newVersion == 1) {
    print("Creating db tables");
    await db.execute(""
        "CREATE TABLE Choreos ("
        "    choreoid INTEGER PRIMARY KEY AUTOINCREMENT,"
        "    title TEXT,"
        "    artists TEXT,"
        "    mapper TEXT,"
        "    difficulty TEXT,"
        "    bpm REAL,"
        "    length TEXT,"
        "    released TEXT,"
        "    url TEXT,"
        "    UNIQUE(url)"
        ")");
    await db.execute(""
        "CREATE TABLE ChoreoFiles ("
        "    fileid INTEGER PRIMARY KEY AUTOINCREMENT,"
        "    choreoid INTEGER,"
        "    file TEXT,"
        "    FOREIGN KEY(choreoid) REFERENCES Choreos(choreoid)"
        "        ON UPDATE CASCADE"
        "        ON DELETE CASCADE"
        ")");
  }
}

_onConfigure(Database db) async {
  // Add support for cascade delete
  await db.execute("PRAGMA foreign_keys = ON");
  await db.execute('PRAGMA encoding = "UTF-8"');
}

final _dbMutex = Mutex();
Database? _dbInstance;

Future<Database> openDB() async {
  final String path = await _ensureDBPath();
  _initDb();

  await _dbMutex.acquire();
  try {
    _dbInstance ??= await openDatabase(
      join(path, "db.sqlite3"),
      version: 1,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
    return _dbInstance!;
  } finally {
    _dbMutex.release();
  }
}

Future closeDB() async {
  await _dbMutex.acquire();
  try {
    await _dbInstance?.close();
    _dbInstance = null;
  } finally {
    _dbMutex.release();
  }
}
