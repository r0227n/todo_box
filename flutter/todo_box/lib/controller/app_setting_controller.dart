import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/todo_box_metadata.dart';
import '../provider/todo_query_provider.dart';

part 'app_setting_controller.g.dart';

@riverpod
class AppSettingController extends _$AppSettingController {
  @override
  FutureOr<TodoBoxMetadata> build() async {
    final query = ref.watch(todoQueryProvider);
    final result = await AsyncValue.guard(() async => await query.listFields(todoBoxMetadataTable));

    // 設定関連のテーブルが存在しない場合、エラーを返す
    assert(result.asData?.value.length == 1);
    final metadata = result.asData!.value.first;
    return TodoBoxMetadata.fromSql(metadata);
  }

  /// state update method
  /// [true]: update success
  /// [false]: update failed
  Future<bool> modified({
    int? id,
    DateTime? notification,
    bool? continueWriiting,
  }) async {
    final sql = ref.read(todoQueryProvider).sqlHelper;

    final oldSate = state.maybeWhen(
      orElse: () => throw StateError('state is not AsyncData'),
      data: (value) => value,
    );
    final newState = oldSate.copyWith(
      id: id ?? oldSate.id,
      notification: notification ?? oldSate.notification,
      continueWriiting: continueWriiting ?? oldSate.continueWriiting,
    );

    state = const AsyncLoading();

    // Sqlの[update]を実行する
    final update = await AsyncValue.guard(() async {
      return await sql.update(
        newState.tableName,
        newState.toSql(),
        whereKey: 'id',
      );
    });

    // Sqlの[update]が成功した場合、stateを更新する
    // Sqlの[update]が失敗した場合、stateを元に戻す
    state = update.maybeWhen(
      orElse: () => AsyncData(oldSate),
      data: (_) => AsyncData(newState),
    );

    return update.hasValue;
  }
}
