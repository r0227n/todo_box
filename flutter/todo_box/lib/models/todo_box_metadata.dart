import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_box_metadata.freezed.dart';
part 'todo_box_metadata.g.dart';

const String todoBoxMetadataTable = 'todo_box_metadata';

@freezed
class TodoBoxMetadata with _$TodoBoxMetadata {
  factory TodoBoxMetadata({
    @Default(todoBoxMetadataTable) String tableName,
    int? id,
    required DateTime notification,
    @JsonKey(name: 'continue_wriiting') required bool continueWriiting,
  }) = _TodoBoxMetadata;

  // SQL Create
  static const String toCreateSql = '''
    CREATE TABLE todo_box_metadata(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      notification TEXT NOT NULL,
      continue_wriiting INTEGER NOT NULL
    )
  ''';

  // from sql
  factory TodoBoxMetadata.fromSql(Map<String, dynamic> map) {
    final json = {
      'id': map['id'],
      'notification': map['notification'],
      'continue_wriiting': map['continue_wriiting'] == 1,
    };

    return TodoBoxMetadata.fromJson(json);
  }

  factory TodoBoxMetadata.fromJson(Map<String, dynamic> json) => _$TodoBoxMetadataFromJson(json);
}
