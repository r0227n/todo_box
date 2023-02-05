import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'bottom_navigation.dart';

extension ExtConsumerWiget on ConsumerWidget {
  BottomNavigation navigationBar() => const BottomNavigation();

  FloatingActionButtonLocation buttonLocation() => FloatingActionButtonLocation.centerDocked;

  FloatingActionButton actionButton(VoidCallback? callback) => FloatingActionButton(
        onPressed: callback,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      );
}
