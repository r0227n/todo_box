import 'package:sqflite/sqflite.dart';

class SqlHeloper {
  SqlHeloper.open(String dbName, this.table, this.key) {
    open(dbName).then((value) => instance = value).catchError((e) => throw ArgumentError(e));
  }

  /// [Database] インスタンス
  late final Database instance;

  /// テーブル名
  final String table;

  /// 主キー
  final String key;

  Future<Database> open(String dbName, {Map<String, String>? columns}) async {
    final databasesPath = await getDatabasesPath();
    final String path = '$databasesPath$dbName.db';

    return await openDatabase(path, version: 1, onCreate: (Database instance, int version) async {
      // テーブルを作成する
      if (columns == null) {
        throw ArgumentError('Column is null');
      }

      String createColumn = "";
      for (final key in columns.keys.toList()) {
        createColumn += "$key ${columns[key]},";
      }

      await instance.execute('''
				create table $table ( 
					$createColumn
				)
			''');
    });
  }

  Future<int> insert(Map<String, Object?> map) async {
    return await instance.insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> select(String id, {List<String>? select}) async {
    return await instance.query(
      table,
      columns: select,
      where: '$key = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    return await instance.delete(
      table,
      where: '$key = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Map<String, Object?> map) async {
    return await instance.update(
      table,
      map,
      where: '$key = ?',
      whereArgs: [map[key]],
    );
  }

  Future close() async => instance.close();
}
