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
    @JsonKey(name: 'continue_writing') required bool continueWriiting,
  }) = _TodoBoxMetadata;

  // SQL Create
  static const String toCreateSql = '''
    CREATE TABLE todo_box_metadata(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      notification TEXT NOT NULL,
      continue_writing INTEGER NOT NULL
    )
  ''';

  // from sql
  factory TodoBoxMetadata.fromSql(Map<String, dynamic> map) {
    final json = {
      'id': map['id'],
      'notification': map['notification'],
      'continue_writing': map['continue_writing'] == 1,
    };

    return TodoBoxMetadata.fromJson(json);
  }

  factory TodoBoxMetadata.fromJson(Map<String, dynamic> json) => _$TodoBoxMetadataFromJson(json);
}

extension TodoBoxMetadataX on TodoBoxMetadata {
  // to sql update
  Map<String, dynamic> toSql({bool containsId = true}) {
    final map = {
      'notification': notification.toIso8601String(),
      'continue_writing': continueWriiting ? 1 : 0,
    };
    if (containsId) {
      map['id'] = id ?? -1;
    }
    return map;
  }
}
