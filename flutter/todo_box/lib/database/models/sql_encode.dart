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

  final String id;

  final String title;

  final int done;

  final DateTime? date;

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
        title: map['title'],
        done: map['done'] == true ? 1 : 0,
        date: map['date'],
        tags: jsonEncode(map['tags']) == '[]' ? null : jsonEncode(map['tags']),
        notification: map['notification'] == true ? 1 : 0,
      );
}
