import 'dart:convert' show jsonEncode;
import '../static/todo_value.dart';

class SqlEncode {
  const SqlEncode({
    required this.id,
    required this.title,
    required this.done,
    required this.date,
    required this.tags,
    required this.notification,
  });

  final int id;

  final String title;

  final int done;

  final String? date;

  final String? tags;

  final int notification;

  Map<String, Object?> toMap() => {
        columnId: id,
        columnTitle: title,
        columnDone: done,
        columnDate: date,
        columnTags: tags,
        columnNotification: notification,
      };

  factory SqlEncode.fromMap(Map<String, dynamic> map) => SqlEncode(
        id: map['id'],
        title: map[columnTitle],
        done: map[columnDone] == true ? 1 : 0,
        date: map[columnDate],
        tags: jsonEncode(map[columnTags]) == '[]' ? null : jsonEncode(map[columnTags]),
        notification: map[columnNotification] == true ? 1 : 0,
      );
}
