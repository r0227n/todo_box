import 'package:flutter/material.dart';
import '../../models/column_type.dart';
import '../../database/helper/sql_helper.dart';
import '../../models/todo.dart';

class TodoQuery {
  const TodoQuery(this.sqlHelper);

  final SqlHeloper sqlHelper;

  final columnType = const ColumnType();

  /// [Database] を閉じる
  void close() async => await sqlHelper.close();

  /// [Todo] をテーブルに追加
  Future<Todo> add({
    int? id,
    required String table,
    required String title,
    required bool done,
    required DateTime? date,
    required List<String> tags,
    required List<NotificationType> notification,
    required List<String> assets,
  }) async {
    final key = await sqlHelper.insert(
      table,
      columnType.toInsert(
        id: id,
        title: title,
        done: done,
        date: date,
        tags: tags,
        notification: notification,
        assets: assets,
      ),
    );

    return Todo(
      id: key,
      table: table,
      title: title,
      done: done,
      date: date,
      tags: tags,
      notification: notification,
      assets: assets,
    );
  }

  /// テーブル内の[Todo]を更新
  Future<int> update(Todo todo) => sqlHelper.update(todo.table, _encode(todo));

  /// テーブル内から[Todo]を削除
  /// [id] はプライマリーキーである[Todo]のid
  Future<int> remove(Todo todo) => sqlHelper.delete(todo.table, todo.id ?? -1);

  Future<void> clear(Todo metadata) =>
      sqlHelper.delete(metadata.table, metadata.id ?? -1, equal: false);

  /// テーブル内から指定した[Todo]を取得
  /// [id] はプライマリーキーである[Todo]のid
  Future<Todo> finad(String table, int id) async {
    final content = await sqlHelper.select(table, id: id);
    return _decode(table, content.first);
  }

  /// テーブル内の[Todo]を全て取得
  /// [name]はテーブル名を指定
  Future<List<Todo>> findAll({required String table, List<String>? where}) async {
    final content = await listFields(table, where: where);
    return content.map((e) => _decode(table, e)).toList();
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
  Future<void> create(String table, String emoji) async {
    try {
      await sqlHelper.createTable(table, columnType.toMap());
      await add(
        id: 0,
        table: table,
        title: '_$emoji' '_$table',
        done: false,
        date: DateTime.now(),
        tags: const <String>[],
        notification: const <NotificationType>[],
        assets: const <String>[],
      );
    } catch (e) {
      throw FlutterError('Failed create tabel: $e');
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
  Todo _decode(String table, Map<String, dynamic> map) {
    final json = {...map, 'table': table};
    return Todo.fromJson(columnType.toDecode(json));
  }
}
