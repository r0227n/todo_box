import 'package:flutter/material.dart';

enum ModCategory {
  calendar,
  image,
  action;
}

enum ModPositioned {
  top,
  bottom,
  dialog;
}

class ModTool {
  const ModTool({
    required this.category,
    required this.position,
  });

  const ModTool.top({
    required this.category,
  }) : position = ModPositioned.top;

  final ModCategory category;
  final ModPositioned position;

  Widget toWidget() {
    switch (category) {
      case ModCategory.calendar:
      case ModCategory.image:
      case ModCategory.action:
        return Container(
          width: 200,
          height: 100,
          color: Colors.green,
        );
    }
  }
}
