import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/static/todo_value.dart';
import '../database/models/todo.dart';
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

  Future<void> add(Todo todo) async {
    final query = ref.read(todoQueryProvider);

    final result = await AsyncValue.guard(() async => await query.add(
          title: todo.title,
          done: todo.done,
          tags: todo.tags ?? [],
          notification: todo.notification,
        ));

    result.maybeWhen(
      orElse: (() {
        // TODO: エラーハンドリング実装
      }),
      data: (data) async => await update((p0) {
        p0.add(data);
        return p0;
      }),
    );
  }

  Future<void> removeAll() async {
    final query = ref.read(todoQueryProvider);
    update((p0) {
      query.removeAll(tableTodo);
      return [];
    });
  }
}
