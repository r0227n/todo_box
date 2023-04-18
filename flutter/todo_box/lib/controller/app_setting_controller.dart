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
}
