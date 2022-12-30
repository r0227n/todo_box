import 'dart:convert' show jsonDecode, jsonEncode;
import '../helper/sql_helper.dart';
import '../models/todo.dart';
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

  Future<int> update(Todo todo) => sqlHelper.update(tableTodo, _encode(todo));

  Future<int> remove(int id) => sqlHelper.delete(tableTodo, id);

  Future<Todo> finad(int id) async {
    final content = await sqlHelper.select(tableTodo, id: id);

    return _decode(content.first);
  }

  Future<List<Todo>> findAll() async {
    final content = await sqlHelper.select(tableTodo);

    return content.map((e) => _decode(e)).toList();
  }

  Future<List<String>> finadAllTable({bool hideDefault = true}) async {
    final tables = await sqlHelper.toListTable();
    if (hideDefault) {
      tables.remove('sqlite_sequence');
    }

    return tables;
  }

  Future<void> create(String name, Map<String, String> column) =>
      sqlHelper.createTable(name, column);

  Future<void> delete(String name) => sqlHelper.deleteTable(name);

  Future<void> deleteAllRow(String table) => sqlHelper.deleteAllRow(table);

  Map<String, dynamic> _encode(Todo todo) {
    final map = todo.toJson();

    return {
      columnId: map['id'],
      columnTitle: map[columnTitle],
      columnDone: map[columnDone] == true ? 1 : 0,
      columnDate: map[columnDate],
      columnTags: jsonEncode(map[columnTags]) == '[]' ? null : jsonEncode(map[columnTags]),
      columnNotification: map[columnNotification] == true ? 1 : 0,
    };
  }

  Todo _decode(Map<String, dynamic> map) => Todo.fromJson({
        columnId: map[columnId],
        columnTitle: map[columnTitle],
        columnDone: map[columnDone] == 0 ? false : true,
        columnDate: DateTime.tryParse(map[columnDate] ?? ''),
        columnTags: map[columnTags] == null ? const <String>[] : jsonDecode(map[columnTags]),
        columnNotification: map[columnNotification] == 0 ? false : true,
      });

  factory TodoQuery.helper(
    String database,
    String table,
    String key,
    Map<String, String>? column,
  ) =>
      TodoQuery(SqlHeloper.open(database, table, key, column));
}
