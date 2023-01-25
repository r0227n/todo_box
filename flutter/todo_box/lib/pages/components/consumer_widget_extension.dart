import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'bottom_navigation.dart';
import '../../controller/todo_controller.dart';
import '../../models/todo.dart';

extension ExtConsumerWiget on ConsumerWidget {
  BottomNavigation navigationBar() => const BottomNavigation();

  FloatingActionButtonLocation buttonLocation() => FloatingActionButtonLocation.centerDocked;

  FloatingActionButton actionButton(WidgetRef ref, FocusNode focusNode) => FloatingActionButton(
        onPressed: () async {
          focusNode.requestFocus();
          await ref
              .read(todoControllerProvider.notifier)
              .add(Todo(title: 'aaa', done: false, date: null, tags: [], notification: []));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      );
}
