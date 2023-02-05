import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/table.dart';
import '../controller/table_controller.dart';

part 'tables_provider.g.dart';

@riverpod
List<Table> tables(TablesRef ref) {
  final AsyncValue<List<Table>> tables = ref.watch(tableControllerProvider);

  return tables.asData?.value ?? const <Table>[];
}
