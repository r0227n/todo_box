/// Table関連の操作を管理するController

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:characters/characters.dart';
import 'query/todo_query.dart';
import '../models/todo.dart';
import '../models/table.dart';
import '../controller/todo_controller.dart';
import '../provider/todo_query_provider.dart';

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

  Future<void> addTodo(Todo todo) async {
    state = await AsyncValue.guard(() async {
      final tables = await future;
      return [
        for (final table in tables)
          if (table.title == todo.table)
            table.copyWith(content: [...table.content, todo.id ?? -1])
          else
            table,
      ];
    });
  }

  Future<void> removeTodo(Todo todo) async {
    state = await AsyncValue.guard(() async {
      final tables = await future;
      print(tables);
      final oldState = tables.firstWhere((t) => t.title == todo.table);
      final newState = [
        for (final id in oldState.content)
          if (id != todo.id) id,
      ];

      return tables.map((e) {
        if (e.title == todo.table) {
          return e.copyWith(content: newState);
        }
        return e;
      }).toList();
    });
  }

  Future<void> clear(Todo metadata) async {
    state = await AsyncValue.guard(() async {
      final tables = await future;
      return [
        for (final table in tables)
          if (table.title == metadata.table)
            table.copyWith(content: [metadata.id ?? -1])
          else
            table,
      ];
    });
  }

  Future<Table?> _findTable(TodoQuery query, TodoController controller, String table) async {
    final result = await AsyncValue.guard(() async => await query.findAll(table: table));
    return result.maybeWhen(
      orElse: (() => null),
      data: ((data) {
        final metadata = data.firstWhere((Todo todo) {
          return todo.title.startsWith('_');
        }, orElse: () => throw StateError('Table metadata is not exist'));
        final decodeTitle = metadata.title.characters.toString();

        data.remove(metadata);

        return Table(
          icon: decodeTitle.substring(1, 3),
          title: table,
          content: data.map((e) => e.id ?? -1).toList(),
        );
      }),
    );
  }
}
