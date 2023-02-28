import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'detail_page.dart';
import 'components/consumer_widget_extension.dart';
import '../controller/todo_controller.dart';
import '../models/todo.dart';

final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

enum PageDisplay {
  page,
  component;

  bool get isPage => this != PageDisplay.page;
  bool get isComponent => this != PageDisplay.component;
}

class ListPage extends ConsumerWidget {
  const ListPage(this.table, {this.display = PageDisplay.page, super.key});

  final String table;
  final PageDisplay display;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(todoControllerProvider);

    return config.when(
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const CircularProgressIndicator(),
      data: (todos) {
        final selectTable = todos
            .where((element) => !element.title.startsWith('_') && element.table == table)
            .toList();

        return Scaffold(
          appBar: display.isPage ? null : AppBar(title: Text(table)),
          body: ListView.builder(
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
                  await ref.read(todoControllerProvider.notifier).remove(selectTable[index]);
                },
                child: ProviderScope(
                  overrides: [_currentTodo.overrideWithValue(selectTable[index])],
                  child: const _ListPageItem(),
                ),
              );
            },
          ),
          bottomNavigationBar: display.isPage ? null : navigationBar(),
          floatingActionButtonLocation: display.isPage ? null : buttonLocation(),
          floatingActionButton: display.isPage ? null : actionButton(null),
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
          onChanged: (_) => ref.read(todoControllerProvider.notifier).toggle(todo),
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
          if (todo == null) {
            return;
          } else if (todo is! Todo) {
            throw FlutterError('$todo is not Todo.');
          }

          final todoCtrl = ref.read(todoControllerProvider.notifier);
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
