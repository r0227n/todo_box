/// Table関連の操作を管理するController

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:characters/characters.dart';
import '../database/query/todo_query.dart';
import '../database/models/todo.dart';
import '../controller/todo_controller.dart';
import '../provider/todo_query_provider.dart';
import '../models/table.dart';

part 'table_controller.g.dart';

@riverpod
class TableController extends _$TableController {
  @override
  FutureOr<List<Table>> build() async {
    final query = ref.watch(todoQueryProvider);
    final todoController = ref.watch(todoControllerProvider.notifier);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => query.listAllTable());

    return result.maybeWhen(
      orElse: (() => const []),
      data: ((data) async {
        final List<Table> tables = [];

        for (final name in data) {
          final table = await _findTable(query, todoController, name);
          if (table == null) {
            continue;
          }
          tables.add(table);
        }

        return tables;
      }),
    );
  }

  Future<Table?> _findTable(TodoQuery query, TodoController controller, String table) async {
    final result = await AsyncValue.guard(() async => await query.findAll(name: table));
    return result.maybeWhen(
      orElse: (() => null),
      data: ((data) {
        final info = data.firstWhere((Todo todo) {
          return todo.title.startsWith('_');
        }, orElse: () => throw StateError('Table Info row is not exist'));
        final decodeInfo = info.title.characters.toString();

        data.remove(info);
        data = data.map((t) => t.copyWith(table: table)).toList();
        controller.addAll(data);

        return Table(
          icon: decodeInfo.substring(1, 3),
          title: info.title.substring(4),
          content: data.map((e) => e.id ?? -1).toList(),
        );
      }),
    );
  }
}
