import 'dart:convert' show base64Encode;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'detail_page.dart';
import 'table_create_field.dart';
import 'list_page.dart';
import 'components/mods.dart';
import 'components/section.dart';
import 'components/emoji_text.dart';
import 'components/consumer_widget_extension.dart';
import '../controller/table_controller.dart';
import '../controller/todo_controller.dart';
import '../controller/local_notification_controller.dart';
import '../models/default_table.dart';
import '../models/table.dart' as sql;
import '../models/todo.dart';

final _currentTable = Provider<sql.Table>((ref) => throw UnimplementedError());

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tableControllerProvider);
    final showKeyboard = useState<bool>(false);

    useEffect(() {
      // アプリ起動時に一度だけ実行
      ref.read(localNotificationProvider.notifier).launchNotificationResponse().then((details) {
        if (details == null) {
          return;
        }

        // アプリ終了状態で通知を開き、でアプリを起動したら詳細画面を表示する
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPage(Todo.fromString(details.payload ?? ''))),
        );
      });
      return null;
    }, const []);

    return config.when(
      loading: () => const CircularProgressIndicator(),
      error: ((error, stackTrace) => Center(
            child: Text('Error $error'),
          )),
      data: (tables) {
        return Scaffold(
          body: KeyboardMods(
            visibleKeyboard: showKeyboard.value,
            chips: tables
                .map((e) => ModActionChip(
                      icon: EmojiText(e.icon),
                      label: e.title,
                    ))
                .toList(),
            selectedChip:
                const ModActionChip(icon: EmojiText(DefaultTable.emoji), label: DefaultTable.name),
            mods: const [
              ModButton.outline(
                chip: ModActionChip(icon: EmojiText(DefaultTable.emoji), label: DefaultTable.name),
                tool: ModTool(position: ModPositioned.top, category: ModCategory.chips),
              ),
              ModButton.outline(
                icon: Icon(Icons.schedule_outlined),
                selectedIcon: Icon(Icons.schedule),
                chip: ModActionChip(icon: Icon(Icons.schedule_outlined), dateTime: null),
                tool: ModTool(position: ModPositioned.dialog, category: ModCategory.time),
              ),
              ModButton.outline(
                icon: Icon(Icons.camera_alt_outlined),
                selectedIcon: Icon(
                  Icons.camera_alt,
                ),
                tool: ModTool(position: ModPositioned.top, category: ModCategory.image),
              ),
            ],
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
                  trailing: IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TableCreateField(),
                      ),
                    ).then((tableInfo) {
                      if (tableInfo is! sql.Table) {
                        return;
                      }

                      final tableCtrl = ref.read(tableControllerProvider.notifier);
                      tableCtrl.create(tableInfo).catchError((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            action: SnackBarAction(
                              label: 'Close',
                              onPressed: () {},
                            ),
                            content: const Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text('Failed to create the List.'),
                            ),
                            duration: const Duration(milliseconds: 3000),
                            margin: const EdgeInsets.symmetric(horizontal: 15.0),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            behavior: SnackBarBehavior.floating,
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          ),
                        );
                      });
                    }),
                    tooltip: 'Add a New List',
                    icon: const Icon(Icons.create_new_folder_outlined),
                  ),
                ),
                Section(
                  ration: 4,
                  borderRadius: 5.0,
                  child: ListView.builder(
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: UniqueKey(),
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
                        onDismissed: (direction) async {
                          final tableCtrl = ref.read(tableControllerProvider.notifier);
                          await tableCtrl.delete(tables[index]);
                        },
                        child: ProviderScope(
                          overrides: [
                            _currentTable.overrideWithValue(tables[index]),
                          ],
                          child: const _TodoItem(),
                        ),
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
              final notificationCtrl = ref.read(localNotificationProvider.notifier);
              final scheduleId = await notificationCtrl.scheduleId;

              final todo = await ref.read(todoControllerProvider(value.selectMenu).notifier).add(
                    Todo(
                      table: value.selectMenu,
                      title: value.text,
                      done: false,
                      date: value.date,
                      tags: [],
                      notification: [scheduleId],
                      assets: value.images.map((e) => base64Encode(e.readAsBytesSync())).toList(),
                    ),
                  );
              if (todo != null && (value.date?.isAfter(DateTime.now()) ?? false)) {
                notificationCtrl.addNotification(
                  'Notification Title',
                  todo.title,
                  todo.date!,
                  id: scheduleId,
                  channel: 'testing',
                  payload: todo.toJson().map((key, value) => MapEntry('"$key"', '"$value"')),
                );
              } else {
                // TODO: エラーハンドリング
              }

              // TODO: 設定で↓の値を切り替える(条件分岐)する項目を入れる
              showKeyboard.value = !showKeyboard.value;
            },
          ),
          bottomNavigationBar: showKeyboard.value ? null : navigationBar(),
          floatingActionButtonLocation: showKeyboard.value ? null : buttonLocation(),
          floatingActionButton: showKeyboard.value
              ? null
              : actionButton(() => showKeyboard.value = !showKeyboard.value),
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
