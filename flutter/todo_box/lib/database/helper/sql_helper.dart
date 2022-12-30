import 'package:sqflite/sqflite.dart';

class SqlHeloper {
  const SqlHeloper(this.instance, this.key);

  /// [Database] インスタンス
  final Database instance;

  /// 主キーの列名
  final String key;

  /// [Database]を開く
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

  /// テーブルを作成
  Future<void> createTable(String table, Map<String, String> column) async {
    String createColumn = "";
    for (final key in column.keys.toList()) {
      createColumn += "$key ${column[key]},";
    }

    createColumn = createColumn.substring(0, createColumn.length - 1);

    await instance.execute('''
			create table $table ( 
				$createColumn
			)
		''');
  }

  /// テーブルを一括取得
  Future<List<String>> toListTable() async {
    return (await instance.query('sqlite_master', columns: const <String>['name']))
        .where((element) => element.values.first != null)
        .map((e) => e.values.first.toString())
        .toList();
  }

  /// [Database]を閉じる
  Future<void> close() async => await instance.close();

  /// 行を追加
  Future<int> insert(String table, Map<String, Object?> map) async {
    return await instance.insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  /// テーブル内から行を検索
  /// [table]: テーブル名
  /// [id]: 主キー
  /// [select]: 検索対象の行。未指定時は全ての値を取得
  Future<List<Map<String, Object?>>> select(String table, {int? id, List<String>? select}) async {
    return await instance.query(
      table,
      columns: select,
      where: id == null ? null : '$key = ?',
      whereArgs: [id],
    );
  }

  /// 行を削除
  /// [table]: テーブル名
  /// [id]: 主キー
  Future<int> delete(String table, int id) async {
    return await instance.delete(
      table,
      where: '$key = ?',
      whereArgs: [id],
    );
  }

  /// 行を全削除
  /// [table]: テーブル名
  Future<void> deleteAllRow(String table) async {
    await instance.execute('''
			delete from $table 
		''');
  }

  /// テーブルを削除
  /// [table]: テーブル名
  Future<void> deleteTable(String table) async {
    await instance.execute('''
      drop table if exists $table
    ''');
  }

  /// 行を更新
  /// [table]: テーブル名
  /// [map]: 行の内容
  Future<int> update(String table, Map<String, Object?> map) async {
    return await instance.update(
      table,
      map,
      where: '$key = ?',
      whereArgs: [map[key]],
    );
  }
}
