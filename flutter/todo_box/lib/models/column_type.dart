import 'dart:convert' show jsonDecode, jsonEncode;

const String defaultEmoji = '📂';
const String defaultTable = 'box';

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
    this.typeNotification = 'INTEGER NOT NULL',
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
    required bool notification,
  }) =>
      {
        this.title: title,
        this.done: done ? 1 : 0,
        this.date: date,
        this.tags: tags.isEmpty ? null : jsonEncode(tags),
        this.notification: notification ? 1 : 0,
      };

  Map<String, dynamic> toDecode(Map<String, dynamic> json) => {
        'id': json[id],
        title: json[title],
        done: json[done] == 0 ? false : true,
        date: DateTime.tryParse(json[date] ?? ''),
        tags: json[tags] == null ? const <String>[] : jsonDecode(json[tags]),
        notification: json[notification] == 0 ? false : true,
      };

  Map<String, dynamic> fromJson(Map<String, dynamic> json) => {
        id: json[id],
        title: json[title],
        done: json[done] == true ? 1 : 0,
        date: json[date],
        tags: jsonEncode(json[tags]) == '[]' ? null : jsonEncode(json[tags]),
        notification: json[notification] == true ? 1 : 0,
      };
}
