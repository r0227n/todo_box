import 'package:flutter/material.dart';
import '../../database/models/todo.dart';

class TodoListView extends StatelessWidget {
  const TodoListView(this.todos, {super.key});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: ((context, index) {
        final todo = todos[index];
        return RadioListTile<bool>(
          tileColor: Colors.red,
          groupValue: todo.done,
          title: Text(todo.title),
          value: todo.done,
          onChanged: (value) {},
        );
      }),
    );
  }
}
