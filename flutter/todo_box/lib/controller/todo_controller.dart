import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_box/controller/table_controller.dart';
import '../models/todo.dart';
import '../provider/todo_query_provider.dart';

part 'todo_controller.g.dart';

@riverpod
class TodoController extends _$TodoController {
  @override
  FutureOr<List<Todo>> build() async {
    final query = ref.watch(todoQueryProvider);
    state = const AsyncLoading();
    final todos = await AsyncValue.guard(() => query.findAll());

    return todos.maybeWhen(
      orElse: (() {
        // TODO: エラーハンドリングを実装する
        // const []は仮置き
        return const [];
      }),
      data: (data) => data,
    );
  }

  Future<Todo?> add(Todo todo) async {
    final query = ref.read(todoQueryProvider);
    final table = ref.read(tableControllerProvider.notifier);

    final result = await AsyncValue.guard(() async => await query.add(
          title: todo.title,
          done: todo.done,
          tags: todo.tags ?? [],
          notification: todo.notification ?? [],
        ));

    return result.maybeWhen(orElse: (() {
      // TODO: エラーハンドリング実装
      return null;
    }), data: (data) async {
      await table.addTodo(data);
      await update((p0) async {
        p0.add(data);

        return p0;
      });

      return data;
    });
  }

  void addAll(List<Todo> todos) async => await update((p0) {
        p0.addAll(todos);
        return p0;
      });

  Future<void> remove(Todo todo) async {
    await ref.read(todoQueryProvider).remove(todo);
    ref.read(tableControllerProvider.notifier).removeTodo(todo);

    await update((p0) {
      p0.remove(todo);
      return p0;
    });
  }

  Future<void> clear(Todo metadata) async {
    await ref.read(todoQueryProvider).clear(metadata);
    ref.read(tableControllerProvider.notifier).clear(metadata);

    state = const AsyncData(<Todo>[]);
  }

  Future<void> toggle(Todo todo) async {
    final newState = todo.copyWith(done: !todo.done);
    ref.read(todoQueryProvider).update(newState);
    state = state.whenData((oldState) => [
          for (final old in oldState)
            if (old == todo) newState else old,
        ]);
  }

  Future<Todo> findMetadata() async {
    final metadata = await AsyncValue.guard(() async {
      final todos = await future;
      return todos.firstWhere((todo) => todo.title.startsWith('_'));
    });

    return metadata.maybeWhen(
      orElse: () => throw StateError('Tabe metadata is not exit'),
      data: (data) => data,
    );
  }
}
