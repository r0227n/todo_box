import 'dart:convert' show base64Encode;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_box/l10n/app_localizations.dart';
import 'detail_page.dart';
import 'components/mods.dart';
import 'components/emoji_text.dart';
import 'components/consumer_widget_extension.dart';
import '../controller/todo_controller.dart';
import '../controller/local_notification_controller.dart';
import '../provider/tables_provider.dart';
import '../models/todo.dart';

final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

enum PageDisplay {
  page,
  component;

  bool get isPage => this != PageDisplay.page;
  bool get isComponent => this != PageDisplay.component;
}

class ListPage extends HookConsumerWidget {
  const ListPage(this.table, {this.display = PageDisplay.page, super.key});

  final String table;
  final PageDisplay display;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(todoControllerProvider(table));
    final tables = ref.watch(tablesProvider);
    final showKeyboard = useState<bool>(false);

    final filterTable = tables.firstWhere((t) => t.title == table, orElse: () => tables.first);

    return config.when(
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const CircularProgressIndicator(),
      data: (todos) {
        final selectTable = todos
            .where((element) => !element.title.startsWith('_') && element.table == table)
            .toList();

        return Scaffold(
          body: KeyboardMods(
            visibleKeyboard: showKeyboard.value,
            visibleAppBar: display.isPage,
            appBarTitle: Text(table),
            chips: tables
                .map((e) => ModActionChip(
                      icon: EmojiText(e.icon),
                      label: e.title,
                    ))
                .toList(),
            selectedChip: ModActionChip(
              icon: EmojiText(filterTable.icon),
              label: filterTable.title,
            ),
            mods: <ModButton>[
              ModButton.outline(
                chip: ModActionChip(icon: EmojiText(filterTable.icon), label: filterTable.title),
                tool: const ModTool(position: ModPositioned.top, category: ModCategory.chips),
              ),
              const ModButton.outline(
                icon: Icon(Icons.schedule_outlined),
                selectedIcon: Icon(Icons.schedule),
                chip: ModActionChip(icon: Icon(Icons.schedule_outlined), dateTime: null),
                tool: ModTool(position: ModPositioned.dialog, category: ModCategory.time),
              ),
              const ModButton.outline(
                icon: Icon(Icons.camera_alt_outlined),
                selectedIcon: Icon(
                  Icons.camera_alt,
                ),
                tool: ModTool(position: ModPositioned.top, category: ModCategory.image),
              ),
            ],
            child: ListView.builder(
              itemCount: selectTable.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const <Widget>[
                          Icon(Icons.delete, color: Colors.white),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  onDismissed: (_) async {
                    await ref
                        .read(todoControllerProvider(table).notifier)
                        .remove(selectTable[index]);
                  },
                  child: ProviderScope(
                    overrides: [_currentTodo.overrideWithValue(selectTable[index])],
                    child: const _ListPageItem(),
                  ),
                );
              },
            ),
            onSwipeDown: () {
              showKeyboard.value = !showKeyboard.value;
            },
            onSubmitted: (value) async {
              final timezonId = context.l10n.timezoneId;
              final notificationCtrl = ref.read(localNotificationProvider.notifier);
              final scheduleId = await notificationCtrl.scheduleId;

              final todo = await ref.read(todoControllerProvider(value.selectMenu).notifier).add(
                    Todo(
                      table: value.selectMenu,
                      title: value.text,
                      done: false,
                      date: value.date,
                      tags: [],
                      notification: [NotificationType(id: scheduleId, schedule: value.schedule)],
                      assets: value.images.map((e) => base64Encode(e.readAsBytesSync())).toList(),
                    ),
                  );
              if (todo != null && (value.date?.isAfter(DateTime.now()) ?? false)) {
                ref.read(localNotificationProvider.notifier).addNotification(
                      'Notification Title',
                      todo.title,
                      todo.date!,
                      id: scheduleId,
                      timezoneId: timezonId,
                      channel: 'testing',
                      payload: todo.toJson(),
                      schedule: value.schedule,
                    );
              } else {
                // TODO: エラーハンドリング
              }

              // TODO: 設定で↓の値を切り替える(条件分岐)する項目を入れる
              showKeyboard.value = !showKeyboard.value;
            },
          ),
          bottomNavigationBar: display.isPage ? null : navigationBar(),
          floatingActionButtonLocation: display.isPage ? null : buttonLocation(),
          floatingActionButton: display.isPage
              ? null
              : showKeyboard.value
                  ? null
                  : actionButton(() => showKeyboard.value = !showKeyboard.value),
        );
      },
    );
  }
}

class _ListPageItem extends ConsumerWidget {
  const _ListPageItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);

    return Material(
      child: ListTile(
        leading: Checkbox(
          checkColor: Colors.white,
          value: todo.done,
          onChanged: (_) => ref.read(todoControllerProvider(todo.table).notifier).toggle(todo),
        ),
        title: Text(
          todo.title,
          style: todo.done
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                )
              : null,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(todo),
          ),
        ).then((todo) async {
          print(todo);
          if (todo == null) {
            return;
          } else if (todo is! Todo) {
            throw FlutterError('$todo is not Todo.');
          }

          final todoCtrl = ref.read(todoControllerProvider(todo.table).notifier);
          await todoCtrl.updateState(todo).catchError((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                action: SnackBarAction(
                  label: 'Close',
                  onPressed: () {},
                ),
                content: const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text('Failed to modify the Todo.'),
                ),
                duration: const Duration(milliseconds: 3000),
                margin: const EdgeInsets.symmetric(horizontal: 15.0),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            );
          });
        }),
      ),
    );
  }
}
