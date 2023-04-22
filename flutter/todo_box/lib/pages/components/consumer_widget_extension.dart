import 'package:flutter/material.dart';
import 'package:todo_box/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'bottom_navigation.dart';

extension ExtConsumerWiget on ConsumerWidget {
  BottomNavigation navigationBar() => const BottomNavigation();

  FloatingActionButtonLocation buttonLocation() => FloatingActionButtonLocation.centerDocked;

  FloatingActionButton actionButton({VoidCallback? onPressed, required BuildContext context}) =>
      FloatingActionButton(
        onPressed: onPressed,
        tooltip: context.l10n.tooltipNewTodo,
        child: const Icon(Icons.add),
      );
}
