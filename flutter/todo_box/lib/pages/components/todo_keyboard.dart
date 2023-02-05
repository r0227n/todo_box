import 'package:flutter/material.dart' show Icons, Icon;
import 'mods.dart';

class TodoKeyboard extends KeyboardMods {
  const TodoKeyboard({
    required super.visibleKeyboard,
    super.mods = const [
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
    required super.child,
    super.menus,
    super.initialMenu,
    super.onSwipeDown,
    super.onSubmitted,
    super.key,
  });
}
