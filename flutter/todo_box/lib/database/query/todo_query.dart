import 'dart:convert' show jsonEncode;
import '../helper/sql_helper.dart';
import '../models/todo.dart';
import '../models/sql_encode.dart';
import '../models/sql_decode.dart';
import '../static/todo_value.dart';

class TodoQuery {
  const TodoQuery(this.sqlHelper);

  final SqlHeloper sqlHelper;

  void close() async => await sqlHelper.close();

  Future<Todo> add({
    required String title,
    required bool done,
    required List<String> tags,
    required bool notification,
    DateTime? date,
  }) async {
    final key = await sqlHelper.insert(tableTodo, {
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

  Future<int> update(Todo todo) async {
    final encode = SqlEncode.fromMap(todo.toJson());
    return await sqlHelper.update(tableTodo, encode.toMap());
  }

  Future<int> remove(int id) async {
    return await sqlHelper.delete(tableTodo, id);
  }

  Future<Todo> finad(int id) async {
    final content = await sqlHelper.select(tableTodo, id);
    final decode = SqlDecode.fromMap(content.first);
    return Todo.fromJson(decode.toMap());
  }

  Future<void> create(String name, Map<String, String> column) async {
    sqlHelper.createTable(name, column);
  }

  Future<void> delete(String name) async {
    await sqlHelper.deleteTable(name);
  }

  Future<List<String>> finadAllTable({bool hideDefault = true}) async {
    final tables = await sqlHelper.toListTable();
    if (hideDefault) {
      tables.remove('sqlite_sequence');
    }

    return tables;
  }

  factory TodoQuery.helper(
    String database,
    String table,
    String key,
    Map<String, String>? column,
  ) =>
      TodoQuery(SqlHeloper.open(database, table, key, column));
}
