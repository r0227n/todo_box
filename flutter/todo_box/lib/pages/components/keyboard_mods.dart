import 'package:flutter/material.dart';
import 'mod_tool.dart';

class KeyboardMods extends StatefulWidget {
  const KeyboardMods({
    required this.parentNode,
    this.focusWidget,
    this.autofocus = false,
    required this.mods,
    required this.child,
    this.topTool,
    this.height = 50.0,
    this.width,
    super.key,
  });

  /// Widget displayed above the keyboard
  final List<Widget> mods;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  final ModTool? topTool;

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              if (widget.topTool is ModTool)
                ValueListenableBuilder(
                  valueListenable: widget.topTool!.select,
                  builder: (context, visible, _) => Visibility(
                    visible: visible,
                    child: widget.topTool!.child,
                  ),
                ),
              Visibility(
                visible: hasFocus() && widget.mods.isNotEmpty,
                child: SizedBox(
                  height: widget.height,
                  width: widget.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: widget.mods,
                  ),
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
