import 'package:flutter/material.dart' show Icons, Icon;
import 'mods.dart';

class TodoKeyboard extends KeyboardMods {
  const TodoKeyboard({
    required super.visibleKeyboard,
    super.mods = const [
      ModButton.outline(
        icon: Icon(Icons.list),
        selectedIcon: Icon(
          Icons.event_available,
        ),
        tool: ModTool(position: ModPositioned.top, category: ModCategory.chips),
      ),
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
      ModButton.outline(
        icon: Icon(Icons.camera_alt_outlined),
        selectedIcon: Icon(
          Icons.camera_alt,
        ),
        tool: ModTool(position: ModPositioned.top, category: ModCategory.image),
      ),
    ],
    required super.child,
    required super.menus,
    required super.initialMenu,
    required super.onSwipeDown,
    required super.onSubmitted,
    super.key,
  });
}
