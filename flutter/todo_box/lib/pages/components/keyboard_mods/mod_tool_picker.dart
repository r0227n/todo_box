import 'package:flutter/material.dart';

class PickerItem {
  const PickerItem({
    required this.onPressed,
    required this.icon,
    required this.title,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final Icon icon;
  final String title;
  final String? tooltip;
}

class ModToolPicker extends StatelessWidget {
  const ModToolPicker({
    super.key,
    this.backgroundColor,
    required this.item,
    this.align = MainAxisAlignment.spaceBetween,
    this.borderColor = const Color(0xFF000000),
  });

  /// [ModToolPicker]'s backgroud color
  final Color? backgroundColor;

  /// [ModToolPicker] displayed item
  final List<PickerItem> item;

  /// [PickerItem]'s align
  final MainAxisAlignment align;

  /// [PickerItem] border color
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final picker in item)
            Tooltip(
              message: picker.tooltip ?? picker.title,
              child: InkWell(
                onTap: picker.onPressed,
                child: Column(
                  mainAxisAlignment: align,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: picker.icon,
                    ),
                    Text(picker.title),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
