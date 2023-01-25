import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../controller/todo_controller.dart';
import '../models/todo.dart';
import 'list_page.dart';
import 'components/section.dart';
import 'components/emoji_text.dart';
import 'components/mods.dart';
import 'components/consumer_widget_extension.dart';
import '../controller/table_controller.dart';
import '../models/table.dart' as sql;

final _currentTable = Provider<sql.Table>((ref) => throw UnimplementedError());

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tableControllerProvider);
    final focus = useFocusNode();

    return config.when(
      loading: () => const CircularProgressIndicator(),
      error: ((error, stackTrace) => Center(
            child: Text('Error $error'),
          )),
      data: (tables) {
        return Scaffold(
          appBar: AppBar(),
          body: KeyboardMods(
            context: context,
            parentNode: focus,
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
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    'Box',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_full_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ListPage(
                          'box',
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
                    'box',
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
            onSubmitted: (value) async {
              await ref.read(todoControllerProvider.notifier).add(
                  Todo(title: value.text, done: false, date: null, tags: [], notification: []));
            },
          ),
          bottomNavigationBar: focus.hasFocus ? null : navigationBar(),
          floatingActionButtonLocation: buttonLocation(),
          floatingActionButton: focus.hasFocus
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    if (focus.hasFocus) {
                      FocusScope.of(context).unfocus();
                    } else {
                      FocusScope.of(context).requestFocus(focus);
                    }

                    // ref.read(localNotificationProvider.notifier).addNotification(
                    //       'Notification Title',
                    //       'Notification Body',
                    //       DateTime.now().millisecondsSinceEpoch + 1000,
                    //       1,
                    //       channel: 'testing',
                    //     );
                  },
                  child: const Icon(Icons.abc),
                ),
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
