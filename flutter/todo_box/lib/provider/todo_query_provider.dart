import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../controller/query/todo_query.dart' show TodoQuery;

part 'todo_query_provider.g.dart';

@riverpod
TodoQuery todoQuery(TodoQueryRef ref) {
  ref.onDispose(() => ref.state.close());

  return throw UnimplementedError();
}
