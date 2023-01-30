import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
          // floatingActionButton: display.isPage ? null : actionButton(ref),
        );
      },
    );
  }
}

class _ListPageItem extends HookConsumerWidget {
  const _ListPageItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Material(
      child: ListTile(
        leading: Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: todo.done,
          onChanged: (bool? value) {
            ref.read(todoControllerProvider.notifier).toggle(todo);
          },
        ),
        title: Text(todo.title),
      ),
    );
  }
}
