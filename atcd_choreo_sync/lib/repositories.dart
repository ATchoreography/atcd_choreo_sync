import 'package:sqflite/sqflite.dart';

import 'model.dart';

abstract class AbstractRepository<T extends ModelObject> {
  final Database db;

  AbstractRepository(this.db);

  String get tableName;

  String get idField;

  T fromMap(Map<String, Object?> map);

  Future<T> insert(T t) async {
    t.id = await db.insert(tableName, t.toMap());
    return t;
  }

  Future<List<T>> getAll() async => (await db.query(tableName)).map((e) => fromMap(e)).toList();

  Future<int> delete(int id) async => db.delete(tableName, where: '$idField = ?', whereArgs: [id]);

  Future<int> update(T t) async => db.update(tableName, t.toMap(), where: '$idField = ?', whereArgs: [t.id]);
}

class ChoreoRepository extends AbstractRepository<Choreo> {
  ChoreoRepository(Database db) : super(db);

  @override
  String get tableName => "Choreos";

  @override
  String get idField => "choreoid";

  @override
  Choreo fromMap(Map<String, Object?> map) => Choreo.fromMap(map);

  Future<Choreo> insertOrUpdateByUrl(Choreo choreo) async {
    List<Map<String, Object?>> result = await db.query(tableName, where: 'url = ?', whereArgs: [choreo.url]);
    if (result.isEmpty) {
      return insert(choreo);
    }
    choreo.id = fromMap(result[0]).id;
    await update(choreo);
    return choreo;
  }
}

class ChoreoFileRepository extends AbstractRepository<ChoreoFile> {
  ChoreoFileRepository(Database db) : super(db);

  @override
  String get tableName => "ChoreoFiles";

  @override
  String get idField => "fileid";

  @override
  ChoreoFile fromMap(Map<String, Object?> map) => ChoreoFile.fromMap(map);

  Future<List<ChoreoFile>> byChoreo(Choreo choreo) async =>
      (await db.query(tableName, where: 'choreoid = ?', whereArgs: [choreo.id])).map((e) => fromMap(e)).toList();
}
