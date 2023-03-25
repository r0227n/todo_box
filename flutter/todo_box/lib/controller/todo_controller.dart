import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_box/controller/local_notification_controller.dart';
import '/controller/table_controller.dart';
import '../models/todo.dart';
import '../provider/todo_query_provider.dart';

part 'todo_controller.g.dart';

@riverpod
class TodoController extends _$TodoController {
  @override
  FutureOr<List<Todo>> build(String table) async {
    final query = ref.watch(todoQueryProvider);
    state = const AsyncLoading();
    final todos = await AsyncValue.guard(() => query.findAll(table: table));
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
          table: todo.table,
          title: todo.title,
          done: todo.done,
          date: todo.date,
          tags: todo.tags.whereType<String>().toList(),
          notification: todo.notification,
          assets: todo.assets.whereType<String>().toList(),
        ));

    return result.maybeWhen(orElse: (() {
      // TODO: エラーハンドリング実装
      return null;
    }), data: (data) async {
      await table.addTodo(data);
      await update((p0) async {
        state = const AsyncLoading();
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
    AsyncValue.guard(() => ref.read(todoQueryProvider).remove(todo)).then((query) {
      if (query.hasError) {
        throw query.asError?.value;
      }
    });
    AsyncValue.guard(() => ref.read(tableControllerProvider.notifier).removeTodo(todo))
        .then((tableCtrl) {
      if (tableCtrl.hasError) {
        throw tableCtrl.asError?.value;
      }
    });

    await update((p0) {
      p0.remove(todo);
      return p0;
    });

    // 通知を削除する
    final localNotificationCtrl = ref.read(localNotificationProvider.notifier);
    AsyncValue.guard(() async {
      final ids = await localNotificationCtrl.existingIds;
      for (var notification in todo.notification) {
        if (ids.contains(notification.id)) {
          localNotificationCtrl.cancelNotification(notification.id);
        }
      }
    }).then((notification) {
      if (notification.hasError) {
        throw notification.asError?.value;
      }
    });
  }

  Future<void> clear(Todo metadata) async {
    await ref.read(todoQueryProvider).clear(metadata);
    ref.read(tableControllerProvider.notifier).clear(metadata);

    state = const AsyncData(<Todo>[]);
  }

  Future<void> toggle(Todo todo) async {
    final newState = todo.copyWith(done: !todo.done);
    await _updateDB(newState).catchError((e) => throw e);
    state = state.whenData((oldState) => [
          for (final old in oldState)
            if (old == todo) newState else old,
        ]);
  }

  /// stateを更新する
  /// [true]: 更新に成功する
  /// [false]: 更新に失敗する
  Future<void> updateState(Todo todo) async {
    final oldState = await future;
    state = const AsyncLoading();
    final newState = await AsyncValue.guard(() async => oldState.map((t) {
          if (t.id != todo.id) {
            return t;
          }
          return todo;
        }).toList());

    newState.maybeWhen(
      orElse: () {
        state = AsyncValue.data(oldState);
        throw StateError(newState.asError?.value);
      },
      data: (data) => state = AsyncValue.data(data),
    );

    await _updateDB(todo).catchError((e) => throw e);
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

  Future<void> _updateDB(Todo todo) async {
    final newState =
        await AsyncValue.guard(() async => await ref.read(todoQueryProvider).update(todo));

    newState.when(
      data: (value) => value,
      error: (error, stackTrace) => throw error,
      loading: () => throw StateError('AsyncValue should not be loading'),
    );
  }
}
