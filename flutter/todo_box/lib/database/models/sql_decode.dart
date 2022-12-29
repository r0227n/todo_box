import 'dart:convert' show jsonDecode;
import '../static/todo_value.dart';

class SqlDecode {
  const SqlDecode({
    required this.id,
    required this.title,
    required this.done,
    required this.date,
    required this.tags,
    required this.notification,
  });

  final int id;

  final String title;

  final bool done;

  final DateTime? date;

  final List<String> tags;

  final bool notification;

  Map<String, Object?> toMap() => {
        columnId: id,
        columnTitle: title,
        columnDone: done,
        columnDate: date,
        columnTags: tags,
        columnNotification: notification,
      };

  factory SqlDecode.fromMap(Map<String, dynamic> map) => SqlDecode(
        id: map[columnId],
        title: map[columnTitle],
        done: map[columnDone] == 0 ? false : true,
        date: DateTime.tryParse(map[columnDate] ?? ''),
        tags: map[columnTags] == null ? const <String>[] : jsonDecode(map[columnTags]),
        notification: map[columnNotification] == 0 ? false : true,
      );
}
