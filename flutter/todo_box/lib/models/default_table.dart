import 'column_type.dart';

class DefaultTable extends ColumnType {
  const DefaultTable();
  static const String emoji = '📂';
  static const String name = 'Box';

  String create() => '''
		CREATE TABLE $name(
      $id $typeId,
      $title $typeTitle,
      $done $typeDone,
      $date $typeDate,
      $tags $typeTags,
      $notification $typeNotification,
      $assets $typeAssets
    )
  ''';

  Map<String, dynamic> insert() => {
        super.title: '_$emoji' '_$name',
        super.done: 0,
        super.date: null,
        super.tags: null,
        super.notification: null,
        super.assets: null
      };

  String path(String path) => '${path}todo.db';
}
