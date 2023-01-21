import 'package:flutter/material.dart';
import 'package:todo_box/pages/components/keyboard_mods/mod_tool.dart';
import 'mod_button.dart';

class KeyboardMods extends StatefulWidget {
  const KeyboardMods({
    required this.parentNode,
    this.autofocus = false,
    required this.mods,
    required this.child,
    this.height = 50.0,
    this.width,
    this.onChange,
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

  final ValueChanged<String>? onChange;

  @override
  State<KeyboardMods> createState() => _KeyboardModsState();
}

class _KeyboardModsState extends State<KeyboardMods> {
  late List<ModButton> modButtons;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    int count = 0;
    modButtons = widget.mods.map((e) => e.copyWith(modIndex: count++, callback: update)).toList();

    _controller.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        } else if (widget.onChange is ValueChanged<String>) {
          widget.onChange!(_controller.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
              GestureDetector(
                onVerticalDragUpdate: (detail) {
                  if (((detail.primaryDelta ?? -1.0) < 0.0) || !hasFocus()) {
                    return;
                  } else if (_controller.text.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                          SnackBar(
                            showCloseIcon: true,
                            action: SnackBarAction(
                              label: 'Restore',
                              onPressed: () {
                                // Code to execute.
                              },
                            ),
                            content: const Text('Discard current task'),
                            duration: const Duration(milliseconds: 3000),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        )
                        .closed
                        .then((closedReason) {
                      if (closedReason == SnackBarClosedReason.action) {
                        FocusScope.of(context).requestFocus(widget.parentNode);
                      } else {
                        _controller.clear();
                      }
                    });
                  }

                  // Close Keyboard
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: TextField(
                  focusNode: widget.parentNode,
                  controller: _controller,
                ),
              ),
              if (hasFocus() && _topModToolButtonItem is ModButton)
                _topModToolButtonItem!.tool.toWidget(),
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

  ModButton? get _topModToolButtonItem {
    final content = modButtons.where((b) => b.select && b.tool.position == ModPositioned.top);
    if (content.isEmpty) {
      return null;
    }

    return content.first;
  }
}
