import 'package:flutter/material.dart';
import 'package:todo_box/l10n/app_localizations.dart';
import 'mod_tool.dart';
import 'mod_button.dart';

class KeyboardMods extends StatefulWidget {
  const KeyboardMods({
    required this.context,
    this.restorationId,
    required this.parentNode,
    this.autofocus = false,
    required this.mods,
    this.menus = const <String>[],
    this.initialMenu,
    required this.child,
    this.height = 50.0,
    this.width,
    this.onChange,
    this.onSubmitted,
    super.key,
  });

  final String? restorationId;

  final BuildContext context;

  /// Widget displayed above the keyboard
  final List<ModButton> mods;

  final List<String> menus;

  final String? initialMenu;

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

  /// Called when the user indicates that they are done editing the text in the [TextField].
  final ValueChanged<ModInputValue>? onSubmitted;

  @override
  State<KeyboardMods> createState() => _KeyboardModsState();
}

class _KeyboardModsState extends State<KeyboardMods> with RestorationMixin {
  late List<ModButton> modButtons;
  late final TextEditingController _controller;

  late final RestorableDateTime _selectedDate;
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture;

  DateTime? _selectDateTime;

  final _menuKey = GlobalKey<PopupMenuButtonState>();
  late String _menuLabel;

  @override
  void initState() {
    super.initState();
    int count = 0;
    modButtons =
        widget.mods.map((e) => e.copyWith(modIndex: count++, callback: _updateState)).toList();

    /// [TextEditingController]'s initialize
    _controller = TextEditingController();
    _controller.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        } else if (widget.onChange is ValueChanged<String>) {
          widget.onChange!(_controller.text);
        }
      });
    });

    /// DatePicker's initialize
    _selectedDate = RestorableDateTime(DateTime.now());
    _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
      onComplete: _selectDate,
      onPresent: (NavigatorState navigator, Object? arguments) {
        return navigator.restorablePush(
          _showDatePickerRoute,
          arguments: _selectedDate.value.millisecondsSinceEpoch,
        );
      },
    );

    _menuLabel = widget.menus.isEmpty ? '' : widget.initialMenu ?? widget.menus.first;
  }

  @override
  void dispose() {
    _controller.dispose();
    _selectedDate.dispose();
    _restorableDatePickerRouteFuture.dispose();
    super.dispose();
  }

  /// Update　when ModButton's pressed.
  void _updateState(ModButton newModButton, int? index) {
    switch (newModButton.tool.category) {
      case ModCategory.calendar:
        _restorableDatePickerRouteFuture.present();
        break;
      case ModCategory.time:
        showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        ).then((time) {
          FocusScope.of(context).requestFocus(widget.parentNode);
          if (time == null) {
            return;
          }

          final now = _selectDateTime ?? DateTime.now();
          _selectDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        });
        break;
      case ModCategory.image:
        // TODO: Handle this case.
        break;
      case ModCategory.action:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  /// Show DateTimePicker
  static Route<DateTime> _showDatePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime.now(),
          lastDate: DateTime(2024),
        );
      },
    );
  }

  void _selectDate(DateTime? newSelectedDate) {
    modButtons = modButtons.map((e) {
      if (e.select) {
        return e.copyWith(select: false);
      }
      return e;
    }).toList();

    if (newSelectedDate != null) {
      // Select Action
      _selectedDate.value = newSelectedDate;
      _selectDateTime = DateTime(
        newSelectedDate.year,
        newSelectedDate.month,
        newSelectedDate.day,
        _selectDateTime?.hour ?? newSelectedDate.hour,
        _selectDateTime?.minute ?? newSelectedDate.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topModButtonTool = _visibleModButton(ModPositioned.top);

    return Stack(
      children: <Widget>[
        Opacity(
          opacity: hasFocus ? 0.8 : 1.0,
          child: widget.child,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Offstage(
              offstage: !hasFocus,
              child: GestureDetector(
                onVerticalDragUpdate: (detail) {
                  if (((detail.primaryDelta ?? -1.0) < 0.0) || !hasFocus) {
                    return;
                  } else if (_controller.text.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                          SnackBar(
                            showCloseIcon: true,
                            action: SnackBarAction(
                              label: 'Restore',
                              onPressed: () {},
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

                  _closeKeyboard;
                },
                child: TextField(
                  focusNode: widget.parentNode,
                  controller: _controller,
                  onSubmitted: (text) {
                    if (mounted && widget.onSubmitted is ValueChanged<ModInputValue>) {
                      widget.onSubmitted!(ModInputValue(text: text, date: _selectDateTime));
                    }
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.green,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(13),
                      ),
                    ),
                    hintText: 'New Todo',
                  ),
                ),
              ),
            ),
            if (hasFocus && widget.menus.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Listener(
                      onPointerDown: (_) {
                        Future.delayed(const Duration(milliseconds: 200)).whenComplete(
                            () => FocusScope.of(context).requestFocus(widget.parentNode));
                        _menuKey.currentState?.showButtonMenu();
                      },
                      child: PopupMenuButton(
                        key: _menuKey,
                        initialValue: widget.initialMenu,
                        offset: const Offset(0, -120),
                        itemBuilder: (context) {
                          return [
                            for (final menuItem in widget.menus)
                              PopupMenuItem(
                                value: menuItem,
                                child: Text(menuItem),
                                onTap: () {
                                  setState(() {
                                    _menuLabel = menuItem;
                                  });
                                },
                              ),
                          ];
                        },
                        child: ListTile(
                          leading: const Icon(
                            Icons.all_inbox,
                            size: 24.0,
                          ),
                          title: Transform.translate(
                            offset: const Offset(-4.0, 0),
                            child: Text(
                              _menuLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_selectDateTime != null)
                    InputChip(
                      label: Text(_selectDateTime!.formatLocal(context.l10n)),
                      onPressed: () {
                        print(_selectDateTime);
                      },
                      onDeleted: () {
                        setState(() {
                          _selectDateTime = null;
                        });
                      },
                    ),
                  const Spacer(),
                ],
              ),
            if (hasFocus && topModButtonTool is ModButton) topModButtonTool.tool.toWidget(),
            if (hasFocus && widget.mods.isNotEmpty)
              Container(
                color: Colors.grey,
                height: widget.height,
                width: widget.width,
                child: Row(
                  children: modButtons,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Whether this node has input focus.
  bool get hasFocus => widget.parentNode.hasFocus;

  ModButton? _visibleModButton(ModPositioned positioned) {
    final content = modButtons.where((b) => b.select && b.tool.position == positioned);
    if (content.isEmpty) {
      return null;
    }

    return content.first;
  }

  // Close Keyboard
  void get _closeKeyboard => FocusManager.instance.primaryFocus?.unfocus();
}

class ModInputValue {
  const ModInputValue({
    required this.text,
    required this.date,
  });

  final String text;
  final DateTime? date;
}
