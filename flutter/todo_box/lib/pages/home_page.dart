import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'list_page.dart';
import 'components/section.dart';
import 'components/emoji_text.dart';
import 'components/mods.dart';
import 'components/consumer_widget_extension.dart';
import '../controller/table_controller.dart';
import '../controller/local_notification_controller.dart';
import '../controller/todo_controller.dart';
import '../models/default_table.dart';
import '../models/todo.dart';
import '../models/table.dart' as sql;

final _currentTable = Provider<sql.Table>((ref) => throw UnimplementedError());

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tableControllerProvider);
    final showKeyboard = useState<bool>(true);

    return config.when(
      loading: () => const CircularProgressIndicator(),
      error: ((error, stackTrace) => Center(
            child: Text('Error $error'),
          )),
      data: (tables) {
        return Scaffold(
          appBar: AppBar(),
          body: KeyboardMods(
            visibleKeyboard: showKeyboard.value,
            mods: const [
              ModButton.outline(
                icon: Icon(Icons.event_available_outlined),
                selectedIcon: Icon(
                  Icons.event_available,
                ),
                tool: ModTool(position: ModPositioned.dialog, category: ModCategory.calendar),
              ),
              ModButton.outline(
                icon: Icon(Icons.schedule_outlined),
                selectedIcon: Icon(
                  Icons.schedule,
                ),
                tool: ModTool(position: ModPositioned.dialog, category: ModCategory.time),
              ),
            ],
            menus: tables.map((e) => e.title).toList(),
            initialMenu: tables
                .firstWhere((t) => t.title == DefaultTable.name, orElse: () => throw Error())
                .title,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    DefaultTable.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_full_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ListPage(
                          DefaultTable.name,
                          display: PageDisplay.page,
                        ),
                        fullscreenDialog: true, // true だとモーダル遷移になる
                      ),
                    ),
                  ),
                ),
                const Section(
                  ration: 3,
                  borderRadius: 8,
                  child: ListPage(
                    DefaultTable.name,
                    display: PageDisplay.component,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Lists',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Section(
                  ration: 4,
                  borderRadius: 5.0,
                  child: ListView.builder(
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      return ProviderScope(
                        overrides: [
                          _currentTable.overrideWithValue(tables[index]),
                        ],
                        child: const _TodoItem(),
                      );
                    },
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 15.0)),
              ],
            ),
            onSwipeDown: () {
              showKeyboard.value = !showKeyboard.value;
            },
            onSubmitted: (value) async {
              final todo = await ref.read(todoControllerProvider.notifier).add(Todo(
                  table: value.selectMenu,
                  title: value.text,
                  done: false,
                  date: value.date,
                  tags: [],
                  notification: [value.date]));
              if (todo != null && (value.date?.isAfter(DateTime.now()) ?? false)) {
                ref.read(localNotificationProvider.notifier).addNotification(
                      'Notification Title',
                      todo.title,
                      todo.date!,
                      todo.id ?? -1,
                      channel: 'testing',
                    );
              } else {
                // TODO: エラーハンドリング
              }
            },
          ),
          bottomNavigationBar: showKeyboard.value ? navigationBar() : null,
          floatingActionButtonLocation: showKeyboard.value ? buttonLocation() : null,
          floatingActionButton: showKeyboard.value
              ? actionButton(() => showKeyboard.value = !showKeyboard.value)
              : null,
        );
      },
    );
  }
}

class _TodoItem extends ConsumerWidget {
  const _TodoItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final table = ref.watch(_currentTable);

    return Card(
      child: ListTile(
        leading: EmojiText(table.icon),
        title: Text(table.title),
        trailing: Text(
          '${table.content.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListPage(
              table.title,
            ),
          ),
        ),
      ),
    );
  }
}
