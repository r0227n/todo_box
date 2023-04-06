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
  Future<void> updateState(Todo todo, String timezoneId) async {
    const updateErrorMessage = 'LocalNotificationUpdateError';

    final oldState = await future;
    state = const AsyncLoading();

    final updateNotification = await AsyncValue.guard<bool>(() async {
      final localNotificationCtrl = ref.read(localNotificationProvider.notifier);

      final currentState = oldState.firstWhere((t) => t.id == todo.id);
      oldState[oldState.indexOf(currentState)] = todo;

      if (todo.date == null) {
        // dateが[null]の場合、通知を削除する
        return await localNotificationCtrl.cancelNotification(todo.notification.first.id);
      } else if (todo.date != null) {
        if (todo.date != currentState.date) {
          // dateが新規追加されていた場合、通知を追加する
          // dateが変更されている場合、通知を更新する
          final notificationId = await localNotificationCtrl.addNotification(
            todo.table,
            todo.title,
            todo.date!,
            id: todo.notification.first.id,
            timezoneId: timezoneId,
            channel: 'testing',
            payload: todo.toJson(),
            schedule: todo.notification.first.schedule,
          );
          return notificationId >= 0;
        } else {
          return false;
        }
      }

      throw StateError('$updateErrorMessage: update notification errror');
    });

    updateNotification.maybeWhen(
      orElse: () {
        state = AsyncValue.error(updateErrorMessage, StackTrace.current);
        throw StateError(updateErrorMessage);
      },
      data: (data) => state = AsyncValue.data(oldState),
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
