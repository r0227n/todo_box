import 'package:flutter/material.dart';
import 'mod_button.dart';

class KeyboardMods extends StatefulWidget {
  const KeyboardMods({
    required this.parentNode,
    this.focusWidget,
    this.autofocus = false,
    required this.mods,
    required this.child,
    this.height = 50.0,
    this.width,
    super.key,
  });

  /// Widget displayed above the keyboard
  final List<ModButton> mods;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Parent [FocusNode]
  final FocusNode parentNode;

  /// Focus widget[focusWidget]of [parentNode]
  final Widget? focusWidget;

  /// [TextField]'s [autofocus] property
  ///
  /// If [focusWidget] is null, use [TextField]
  /// Auto focus if set to [true]
  final bool autofocus;

  /// Height of [mods] displayed above keyboard
  /// default value is 50.0
  final double height;

  /// Width of [mods] displayed above keyboard
  final double? width;

  @override
  State<KeyboardMods> createState() => _KeyboardModsState();
}

class _KeyboardModsState extends State<KeyboardMods> {
  late List<ModButton> modButtons;

  @override
  void initState() {
    super.initState();
    int count = 0;
    modButtons = widget.mods.map((e) => e.copyWith(modIndex: count++, callback: update)).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void update(ModButton newModButton, int? index) {
    if (index is int) {
      setState(() {
        modButtons = modButtons.map((e) {
          if (e.modIndex == index) {
            return e;
          }
          return e.copyWith(select: false);
        }).toList();
        modButtons[index] = newModButton.copyWith(select: !newModButton.select);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        Offstage(
          offstage: !hasFocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widget.focusWidget ??
                  TextField(
                    focusNode: widget.parentNode,
                  ),
              for (final ModButton button in modButtons)
                if (button.select) button.tool.toWidget(),
              if (hasFocus() && widget.mods.isNotEmpty)
                SizedBox(
                  height: widget.height,
                  width: widget.width,
                  child: Row(
                    children: modButtons,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Whether this node has input focus.
  bool hasFocus() => widget.parentNode.hasFocus;
}
