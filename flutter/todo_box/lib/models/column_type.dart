import 'dart:convert' show jsonDecode, jsonEncode;

class ColumnType {
  const ColumnType({
    this.typeId = 'INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL',
    this.id = '_id',
    this.typeTitle = 'TEXT NOT NULL',
    this.title = 'title',
    this.typeDone = 'INTEGER NOT NULL',
    this.done = 'done',
    this.typeDate = 'TEXT NULL',
    this.date = 'date',
    this.typeTags = 'TEXT NULL',
    this.tags = 'tags',
    this.typeNotification = 'TEXT NULL',
    this.notification = 'notification',
  });

  final String typeId;
  final String id;
  final String typeTitle;
  final String title;
  final String typeDone;
  final String done;
  final String typeDate;
  final String date;
  final String typeTags;
  final String tags;
  final String typeNotification;
  final String notification;

  Map<String, String> toMap() => {
        id: typeId,
        title: typeTitle,
        done: typeDone,
        date: typeDate,
        tags: typeTags,
        notification: typeNotification,
      };

  Map<String, dynamic> toInsert({
    required String title,
    required bool done,
    required DateTime? date,
    required List<String> tags,
    required List<DateTime?> notification,
  }) =>
      {
        this.title: title,
        this.done: done ? 1 : 0,
        this.date: date is DateTime ? date.toIso8601String() : null,
        this.tags: tags.isEmpty ? null : jsonEncode(tags),
        this.notification: notification.isEmpty
            ? null
            : jsonEncode(notification.map((e) {
                if (e != null) {
                  return e.toIso8601String();
                }
                return e;
              }).toList()),
      };

  Map<String, dynamic> toDecode(Map<String, dynamic> json) => {
        '_id': json[id],
        title: json[title],
        done: json[done] == 0 ? false : true,
        date: json[date],
        tags: json[tags] == null ? const <String>[] : jsonDecode(json[tags]),
        notification:
            json[notification] == null ? const <DateTime>[] : jsonDecode(json[notification]),
      };

  Map<String, dynamic> fromJson(Map<String, dynamic> json) => {
        id: json['_id'],
        title: json[title],
        done: json[done] == true ? 1 : 0,
        date: json[date],
        tags: jsonEncode(json[tags]) == 'null' ? null : jsonEncode(json[tags]),
        notification:
            jsonEncode(json[notification]) == 'null' ? null : jsonEncode(json[notification]),
      };
}
