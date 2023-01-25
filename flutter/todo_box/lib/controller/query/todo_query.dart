import '../../models/column_type.dart';
import '../../database/helper/sql_helper.dart';
import '../../models/todo.dart';

class TodoQuery {
  const TodoQuery(this.sqlHelper, this.table);

  final SqlHeloper sqlHelper;

  /// テーブル名
  final String table;

  final columnType = const ColumnType();

  /// [Database] を閉じる
  void close() async => await sqlHelper.close();

  /// [Todo] をテーブルに追加
  Future<Todo> add({
    required String title,
    required bool done,
    required List<String> tags,
    required List<DateTime> notification,
    DateTime? date,
  }) async {
    final key = await sqlHelper.insert(
      table,
      columnType.toInsert(
        title: title,
        done: done,
        date: date,
        tags: tags,
        notification: notification,
      ),
    );
    print(key);

    return Todo(
      id: key,
      title: title,
      done: done,
      date: date,
      tags: tags,
      notification: notification,
    );
  }

  /// テーブル内の[Todo]を更新
  Future<int> update(Todo todo) => sqlHelper.update(table, _encode(todo));

  /// テーブル内から[Todo]を削除
  /// [id] はプライマリーキーである[Todo]のid
  Future<int> remove(Todo todo) => sqlHelper.delete(todo.table, todo.id ?? -1);

  Future<void> clear(Todo metadata) =>
      sqlHelper.delete(metadata.table, metadata.id ?? -1, equal: false);

  /// テーブル内から指定した[Todo]を取得
  /// [id] はプライマリーキーである[Todo]のid
  Future<Todo> finad(int id) async {
    final content = await sqlHelper.select(table, id: id);

    return _decode(content.first);
  }

  /// テーブル内の[Todo]を全て取得
  /// [name]はテーブル名を指定
  Future<List<Todo>> findAll({String? name, List<String>? where}) async {
    final content = await listFields(name ?? table, where: where);
    print(content.first);
    return content.map((e) => _decode(e)).toList();
  }

  Future<List<Map<String, dynamic>>> listFields(String name, {List<String>? where}) =>
      sqlHelper.select(name, select: where);

  /// データベース内のテーブル名を一覧取得
  Future<List<String>> listAllTable({bool hideDefault = true}) async {
    final tables = await sqlHelper.toListTable();
    if (hideDefault) {
      tables.remove('sqlite_sequence');
    }

    return tables;
  }

  /// テーブルを新規作成
  /// [name]はテーブル名を指定
  /// [column]は列の名前を[key]、プロパティを[value]
  Future<void> create(String name, String emoji, Map<String, String> column) async {
    try {
      await sqlHelper.createTable(name, columnType.toMap());
      await add(title: '_$emoji' '_$name', done: false, tags: const [], notification: []);
    } catch (e) {
      throw 'Failed create tabel: $e';
    }
  }

  /// テーブルを削除
  /// [name]はテーブル名を指定
  Future<void> delete(String name) => sqlHelper.deleteTable(name);

  /// SQLが対応している形式にエンコード
  Map<String, dynamic> _encode(Todo todo) {
    final map = todo.toJson();

    return columnType.fromJson(map);
  }

  /// SQL用にエンコードされたデータをデコード
  Todo _decode(Map<String, dynamic> map) => Todo.fromJson(columnType.toDecode(map));
}
