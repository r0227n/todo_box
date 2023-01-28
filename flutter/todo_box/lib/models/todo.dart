import 'package:freezed_annotation/freezed_annotation.dart';
import 'default_table.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
class Todo with _$Todo {
  factory Todo({
    @Default(DefaultTable.name) String table,
    int? id,
    required String title,
    required bool done,
    required DateTime? date,
    required List<String>? tags,
    required List<DateTime?> notification,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
