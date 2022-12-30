import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controller/todo_controller.dart';
import '../database/models/todo.dart';
import 'components/todo_list_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(todoControllerProvider);

    return config.when(
      loading: () => const CircularProgressIndicator(),
      error: ((error, stackTrace) => Text('Error $error')),
      data: (todo) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: TodoListView(todo),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final query = ref.read(todoControllerProvider.notifier);

              var num = await query.add(
                Todo(
                  title: "test",
                  done: true,
                  tags: [],
                  notification: false,
                  date: null,
                ),
              );
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
