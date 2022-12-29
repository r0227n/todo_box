import 'package:sqflite/sqflite.dart';

class SqlHeloper {
  SqlHeloper.open(String database, String table, this.key, Map<String, String>? column) {
    open(database, table, column: column)
        .then((value) => instance = value)
        .catchError((e) => throw ArgumentError(e));
  }

  /// [Database] インスタンス
  late final Database instance;

  /// 主キー
  final String key;

  Future<Database> open(String database, String table, {Map<String, String>? column}) async {
    final databasesPath = await getDatabasesPath();
    final String path = '$databasesPath$database.db';

    return await openDatabase(path, version: 1, onCreate: (Database instance, int version) async {
      // テーブルを作成する
      if (column == null) {
        throw ArgumentError('Column is null');
      }

      await createTable(table, column);
    });
  }

  Future<void> createTable(String table, Map<String, String> column) async {
    String createColumn = "";
    for (final key in column.keys.toList()) {
      createColumn += "$key ${column[key]},";
    }

    await instance.execute('''
			create table $table ( 
				$createColumn
			)
		''');
  }

  Future<List<String>> toListTable() async {
    return (await instance.query('sqlite_master', columns: const <String>['name']))
        .where((element) => element.values.first != null)
        .map((e) => e.values.first.toString())
        .toList();
  }

  Future<void> close() async => await instance.close();

  Future<int> insert(String table, Map<String, Object?> map) async {
    return await instance.insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  Future<List<Map<String, Object?>>> select(String table, int id, {List<String>? select}) async {
    return await instance.query(
      table,
      columns: select,
      where: '$key = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, int id) async {
    return await instance.delete(
      table,
      where: '$key = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(String table, Map<String, Object?> map) async {
    return await instance.update(
      table,
      map,
      where: '$key = ?',
      whereArgs: [map[key]],
    );
  }
}
