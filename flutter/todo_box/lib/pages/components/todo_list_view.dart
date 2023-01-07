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
        return CheckboxListTile(
          tileColor: Colors.red,
          title: Text(todo.title),
          controlAffinity: ListTileControlAffinity.leading,
          value: todo.done,
          onChanged: (bool? value) {},
        );
      }),
    );
  }
}
