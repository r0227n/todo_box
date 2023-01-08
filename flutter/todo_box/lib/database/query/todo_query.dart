import 'dart:convert' show jsonDecode, jsonEncode;

import '../helper/sql_helper.dart';
import '../models/todo.dart';
import '../static/todo_value.dart';

class TodoQuery {
  const TodoQuery(this.sqlHelper, this.table);

  final SqlHeloper sqlHelper;

  /// テーブル名
  final String table;

  /// [Database] を閉じる
  void close() async => await sqlHelper.close();

  /// [Todo] をテーブルに追加
  Future<Todo> add({
    required String title,
    required bool done,
    required List<String> tags,
    required bool notification,
    DateTime? date,
  }) async {
    final key = await sqlHelper.insert(table, {
      columnTitle: title,
      columnDone: done ? 1 : 0,
      columnDate: date,
      columnTags: tags.isEmpty ? null : jsonEncode(tags),
      columnNotification: notification ? 1 : 0,
    });

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
  Future<int> remove(int id) => sqlHelper.delete(table, id);

  Future<void> removeAll(String table) => sqlHelper.deleteAllRow(table);

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
      await sqlHelper.createTable(name, column);
      add(title: '_$emoji' '_$name', done: false, tags: const [], notification: false);
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

    return {
      columnId: map[columnId],
      columnTitle: map[columnTitle],
      columnDone: map[columnDone] == true ? 1 : 0,
      columnDate: map[columnDate],
      columnTags: jsonEncode(map[columnTags]) == '[]' ? null : jsonEncode(map[columnTags]),
      columnNotification: map[columnNotification] == true ? 1 : 0,
    };
  }

  /// SQL用にエンコードされたデータをデコード
  Todo _decode(Map<String, dynamic> map) => Todo.fromJson({
        'id': map[columnId],
        columnTitle: map[columnTitle],
        columnDone: map[columnDone] == 0 ? false : true,
        columnDate: DateTime.tryParse(map[columnDate] ?? ''),
        columnTags: map[columnTags] == null ? const <String>[] : jsonDecode(map[columnTags]),
        columnNotification: map[columnNotification] == 0 ? false : true,
      });
}
