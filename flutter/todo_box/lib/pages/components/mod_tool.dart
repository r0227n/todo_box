import 'package:flutter/material.dart' show Widget, ValueNotifier;

enum ModPosition {
  top,
  bottom;
}

class ModTool {
  const ModTool({
    required this.position,
    required this.select,
    required this.child,
  });

  final ModPosition position;
  final ValueNotifier<bool> select;
  final Widget child;
}
