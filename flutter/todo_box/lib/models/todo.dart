import 'dart:convert' show jsonDecode;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
class Todo with _$Todo {
  factory Todo({
    required String table,
    @JsonKey(name: '_id') int? id,
    required String title,
    required bool done,
    required DateTime? date,
    required List<String?> tags,
    required List<int> notification,
    required List<String> assets,
  }) = _Todo;

  factory Todo.fromString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<String> notification =
        json['notification'].replaceAll('[', '').replaceAll(']', '').split(',');

    return Todo(
      table: json['table'],
      id: int.tryParse(json['_id']),
      title: json['title'],
      done: json['done'] == 'true',
      date: DateTime.tryParse(json['date']),
      tags: json['tags'].replaceAll('[', '').replaceAll(']', '').split(','),
      notification: notification.map((e) => int.parse(e)).toList(),
      assets: json['assets'].replaceAll('[', '').replaceAll(']', '').split(','),
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
