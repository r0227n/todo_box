import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/todo_box_metadata.dart';
import '../provider/todo_query_provider.dart';

part 'app_setting_controller.g.dart';

@riverpod
class AppSettingController extends _$AppSettingController {
  @override
  FutureOr<TodoBoxMetadata> build() async {
    final query = ref.watch(todoQueryProvider);
    final result = await AsyncValue.guard(() => query.listFields(todoBoxMetadataTable));

    // 設定関連のテーブルが存在しない場合、エラーを返す
    assert(result.asData?.value.length == 1);
    final metadata = result.asData!.value.first;
    return TodoBoxMetadata.fromSql(metadata);
  }

  /// state update method
  Future<void> modified({
    int? id,
    DateTime? notification,
    bool? continueWriiting,
  }) async {
    final oldSate = state.asData?.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newState = oldSate?.copyWith(
        id: id ?? oldSate.id,
        notification: notification ?? oldSate.notification,
        continueWriiting: continueWriiting ?? oldSate.continueWriiting,
      );
      assert(newState != null);

      // TODO: SQLの更新処理を実装する

      return newState!;
    });
  }
}
