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
    this.typeAssets = 'TEXT NULL',
    this.assets = 'assets',
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
  final String typeAssets;
  final String assets;

  Map<String, String> toMap() => {
        id: typeId,
        title: typeTitle,
        done: typeDone,
        date: typeDate,
        tags: typeTags,
        notification: typeNotification,
        assets: typeAssets,
      };

  Map<String, dynamic> toInsert({
    int? id,
    required String title,
    required bool done,
    required DateTime? date,
    required List<String> tags,
    required List<int> notification,
    required List<String> assets,
  }) {
    if (id == null) {
      return {
        this.title: title,
        this.done: done ? 1 : 0,
        this.date: date is DateTime ? date.toIso8601String() : null,
        this.tags: tags.isEmpty ? null : jsonEncode(tags),
        this.notification: notification.isEmpty ? null : jsonEncode(notification),
        this.assets: assets.isEmpty ? null : jsonEncode(assets),
      };
    }

    return {
      this.id: id,
      this.title: title,
      this.done: done ? 1 : 0,
      this.date: date is DateTime ? date.toIso8601String() : null,
      this.tags: tags.isEmpty ? null : jsonEncode(tags),
      this.notification: notification.isEmpty ? null : jsonEncode(notification),
      this.assets: assets.isEmpty ? null : jsonEncode(assets),
    };
  }

  Map<String, dynamic> toDecode(Map<String, dynamic> json) => {
        '_id': json[id],
        'table': json['table'],
        title: json[title],
        done: json[done] == 0 ? false : true,
        date: json[date],
        tags: json[tags] == null ? const <String>[] : jsonDecode(json[tags]),
        notification: json[notification] == null ? const <int>[] : jsonDecode(json[notification]),
        assets: json[assets] == null ? const <String>[] : jsonDecode(json[assets]),
      };

  Map<String, dynamic> fromJson(Map<String, dynamic> json) => {
        id: json['_id'],
        title: json[title],
        done: json[done] == true ? 1 : 0,
        date: json[date],
        tags: jsonEncode(json[tags]) == 'null' ? null : jsonEncode(json[tags]),
        notification:
            jsonEncode(json[notification]) == 'null' ? null : jsonEncode(json[notification]),
        assets: jsonEncode(json[assets]) == 'null' ? null : jsonEncode(json[assets]),
      };
}
