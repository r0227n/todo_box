import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_box/l10n/app_localizations.dart';
import 'mod_tool.dart';
import 'mod_button.dart';
import 'mod_tool_picker.dart';
import '../../detail_image.dart';

class KeyboardMods extends StatefulWidget {
  const KeyboardMods({
    this.restorationId,
    required this.visibleKeyboard,
    this.autofocus = false,
    required this.mods,
    required this.selectedChip,
    this.chips = const <ModActionChip>[],
    required this.child,
    this.height = 50.0,
    this.width,
    this.onChange,
    this.onSwipeDown,
    this.onSubmitted,
    super.key,
  });

  final String? restorationId;

  /// Widget displayed above the keyboard
  final List<ModButton> mods;

  final List<ModActionChip> chips;
  final ModActionChip selectedChip;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  final bool visibleKeyboard;

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

  /// Notification swipe down for [TextField]
  final ValueGetter? onSwipeDown;

  /// Called when the user indicates that they are done editing the text in the [TextField].
  final ValueChanged<ModInputValue>? onSubmitted;

  @override
  State<KeyboardMods> createState() => _KeyboardModsState();
}

class _KeyboardModsState extends State<KeyboardMods> {
// class _KeyboardModsState extends State<KeyboardMods> with RestorationMixin {
  late final FocusNode _node;

  late List<ModButton> modButtons;
  late final TextEditingController _controller;

  late final RestorableDateTime _selectedDate;
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture;

  DateTime? _selectDateTime;

  final ImagePicker _picker = ImagePicker();
  final List<File> _pickFiles = <File>[];

  late ModActionChip _selectedChip;

  bool _visibleToolBar = false;
  Widget? _modToolWidgetState;

  late final _now;

  @override
  void initState() {
    super.initState();
    _node = FocusNode(debugLabel: 'KeyboardMods');

    int count = 0;
    modButtons = widget.mods
        .map((e) => e.copyWith(modIndex: count++, callback: _updateState, onDeleted: delete))
        .toList();

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

    _selectedChip = widget.selectedChip;
    _now = DateTime.now();
  }

  /// 親Widgetが再描画したタイミングで呼び出される
  @override
  void didUpdateWidget(covariant KeyboardMods oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visibleKeyboard) {
      FocusScope.of(context).requestFocus(_node);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _node.dispose();
    _controller.dispose();
    super.dispose();
  }

  final ValueNotifier<DateTime?> _time = ValueNotifier<DateTime?>(null);
  int? modCategoryState;

  /// Update　when ModButton's pressed.
  Future<void> _updateState(ModButton newModButton, int? index) async {
    // [_modToolWidgetState] reset state
    if (index == null) {
      return;
    } else if (_modToolWidgetState != null) {
      _modToolWidgetState = null;
    }

    switch (newModButton.tool.category) {
      case ModCategory.chips:
        setState(() {
          _modToolWidgetState = _ModActionChipTool(
            chips: widget.chips,
            selectedChip: _selectedChip,
            onPressed: (chip) {
              setState(() {
                modButtons[index] = newModButton.copyWith(chip: chip);
                _selectedChip = chip;
              });
            },
          );
        });

        break;
      case ModCategory.calendar:
        setState(() {
          _modToolWidgetState = ValueListenableBuilder(
            valueListenable: _time,
            builder: (context, value, child) {
              return _ModActionDateTime(
                initDateTime: _now,
                dateTime: value,
                onDatePicker: (value) {
                  setState(() {
                    _time.value = value;
                  });
                },
                onTimePicker: (value) {
                  setState(() {
                    _time.value = value;
                  });
                },
                onApply: () {
                  setState(() {
                    modButtons = modButtons.map((e) {
                      if (e.modIndex != index) {
                        return e;
                      }

                      return e.copyWith(chip: e.chip?.copyWith(dateTime: value));
                    }).toList();
                  });
                },
              );
            },
          );
        });

        break;
      case ModCategory.time:
        showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        ).then((time) {
          FocusScope.of(context).requestFocus(_node);
          if (time == null) {
            return;
          }

          final now = _selectDateTime ?? DateTime.now();
          _selectDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        });
        break;
      case ModCategory.image:
        // setState(() {
        //   modButtons[index] = newModButton.copyWith(select: !newModButton.select);
        // });
        break;
      case ModCategory.action:
        // TODO: Handle this case.
        break;
    }

    setState(() {
      _visibleToolBar = !_visibleToolBar;
      modCategoryState = index;
      modButtons = modButtons.map((e) {
        if (e.modIndex == index) {
          return e.copyWith(select: !e.select);
        }
        return e;
      }).toList();
    });
  }

  void delete() {
    final test = modButtons.where((element) => element.chip?.dateTime != null).toList();
    if (test.isNotEmpty) {
      if (test.length != 1) {
        throw FlutterError('Error KeyboardMods State');
      }
      final aaa = modButtons[modButtons.indexOf(test.first)];
      setState(() {
        modButtons[modButtons.indexOf(test.first)] =
            aaa.copyWith(select: !aaa.select, chip: aaa.chip?.copyWith(dateTime: null));
      });
    }
    _time.value = null;
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

  /// [RestorableRouteFuture]'s [onComplete] action
  /// 日付選択ダイアログが閉じた後のアクション
  void _selectDate(DateTime? newSelectedDate) {
    // Cancel Action
    if (newSelectedDate == null) {
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    final topModButtonTool = _visibleModButton(ModPositioned.top);

    return Scaffold(
      appBar: AppBar(
        actions: [
          SingleChildScrollView(
            child: SizedBox(
              height: kBottomNavigationBarHeight,
              width: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final file in _pickFiles)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailImage(
                              files: _pickFiles,
                              index: _pickFiles.indexOf(file),
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      onLongPress: () {
                        _picker.pickImage(source: ImageSource.gallery).then((newState) {
                          if (newState == null) {
                            return;
                          }

                          final index = _pickFiles.indexOf(file);
                          setState(() {
                            _pickFiles[index] = File(newState.path);
                          });
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Image.file(file),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Opacity(
            opacity: _node.hasFocus ? 0.8 : 1.0,
            child: widget.child,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Offstage(
                offstage: !_node.hasFocus,
                child: GestureDetector(
                  onVerticalDragUpdate: (detail) {
                    if (((detail.primaryDelta ?? -1.0) < 0.0) || !_node.hasFocus) {
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
                          FocusScope.of(context).requestFocus(_node);
                        } else {
                          _controller.clear();
                        }
                      });
                    }
                    FocusScope.of(context).unfocus();

                    // Notification dwipe down
                    if (widget.onSwipeDown is ValueGetter) {
                      widget.onSwipeDown!();
                    }
                  },
                  child: TextField(
                    focusNode: _node,
                    controller: _controller,
                    onSubmitted: (text) {
                      if (mounted && widget.onSubmitted is ValueChanged<ModInputValue>) {
                        widget.onSubmitted!(ModInputValue(
                          text: text,
                          selectMenu: '', // TODO: ActionChipで選択されているラベルを入れる
                          date: _selectDateTime,
                        ));
                      }
                      _controller.clear();
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
              if (_node.hasFocus && _visibleToolBar && _modToolWidgetState != null)
                SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: _modToolWidgetState,
                ),
              // if (_node.hasFocus && topModButtonTool is ModButton) topModButtonTool.tool.toWidget(),
              if (_node.hasFocus && topModButtonTool is ModButton)
                ModToolPicker(
                  item: [
                    PickerItem(
                      onPressed: () {
                        // ModButtonがキーボードに隠れるのを防ぐため、一時的な対応策として実施
                        FocusScope.of(context).unfocus();

                        _picker.pickImage(source: ImageSource.gallery).then((pickedFile) {
                          // ModButtonがキーボードに隠れるのを防ぐため、一時的な対応策として実施
                          FocusScope.of(context).requestFocus(_node);

                          setState(() {
                            modButtons = modButtons.map((e) {
                              if (e.select) {
                                return e.copyWith(select: !e.select);
                              }

                              return e;
                            }).toList();
                            if (pickedFile != null) {
                              _pickFiles.add(File(pickedFile.path));
                            }
                          });
                        });
                      },
                      icon: const Icon(
                        Icons.abc,
                        size: 36.0,
                      ),
                      title: 'test',
                    ),
                  ],
                ),
              if (_node.hasFocus && widget.mods.isNotEmpty)
                Container(
                  color: Colors.grey,
                  height: widget.height,
                  width: widget.width,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: modButtons,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ModButton? _visibleModButton(ModPositioned positioned) {
    final content = modButtons.where((b) => b.select && b.tool.position == positioned);
    if (content.isEmpty) {
      return null;
    }

    return content.first;
  }
}

class ModInputValue {
  const ModInputValue({
    required this.text,
    required this.selectMenu,
    required this.date,
  });

  final String text;
  final String selectMenu;
  final DateTime? date;
}

class ModActionChip {
  const ModActionChip({
    required this.icon,
    this.label,
    this.dateTime,
    this.onDeleted,
  });

  final Widget icon;
  final String? label;
  final DateTime? dateTime;
  final VoidCallback? onDeleted;

  ModActionChip copyWith({
    Widget? icon,
    String? label,
    DateTime? dateTime,
    VoidCallback? onDeleted,
  }) =>
      ModActionChip(
        icon: icon ?? this.icon,
        label: label ?? this.label,
        dateTime: dateTime ?? this.dateTime,
        onDeleted: onDeleted ?? this.onDeleted,
      );
}

class _ModActionChipTool extends StatelessWidget {
  const _ModActionChipTool({
    required this.chips,
    required this.selectedChip,
    required this.onPressed,
  });

  final List<ModActionChip> chips;
  final ModActionChip selectedChip;
  final ValueChanged<ModActionChip> onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final chip in chips)
          ActionChip(
            shape: const StadiumBorder(side: BorderSide()),
            avatar: FittedBox(child: chip.icon),
            label: Text(chip.label ?? chip.dateTime?.formatLocal(context.l10n) ?? ''),
            onPressed: chips.contains(selectedChip) ? () => onPressed(chip) : null,
          ),
      ],
    );
  }
}

class _ModActionDateTime extends StatelessWidget {
  const _ModActionDateTime({
    required this.initDateTime,
    this.dateTime,
    required this.onDatePicker,
    required this.onTimePicker,
    required this.onApply,
  });

  final DateTime initDateTime;
  final DateTime? dateTime;
  final ValueChanged<DateTime> onDatePicker;
  final ValueChanged<DateTime> onTimePicker;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _padding,
          Expanded(
            flex: 4,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                side: const BorderSide(width: 0.5),
              ),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2024),
                );
                if (date == null) {
                  return;
                }

                onDatePicker(DateTime(
                  date.year,
                  date.month,
                  date.day,
                  date.hour == 0 ? initDateTime.hour : 0,
                  date.minute == 0 ? initDateTime.minute : 0,
                  date.second == 0 ? initDateTime.second : 0,
                  date.millisecond == 0 ? initDateTime.millisecond : 0,
                ));
              },
              child: Text(dateTime?.toYYYYMMdd(context.l10n) ?? 'null'),
            ),
          ),
          _padding,
          Expanded(
            flex: 4,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                side: const BorderSide(width: 0.5),
              ),
              onPressed: () async {
                final time = await showTimePicker(
                  initialTime: TimeOfDay.now(),
                  context: context,
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );

                if (time == null) {
                  return;
                }

                onTimePicker(DateTime(
                  dateTime?.year ?? initDateTime.year,
                  dateTime?.month ?? initDateTime.month,
                  dateTime?.day ?? initDateTime.day,
                  time.hour,
                  time.minute,
                  initDateTime.second,
                  initDateTime.millisecond,
                ));
              },
              child: Text(dateTime?.toHHmm(context.l10n) ?? 'null'),
            ),
          ),
          _padding,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
            ),
            onPressed: () => onApply(),
            child: const Text('Apply'),
          ),
          _padding,
        ],
      ),
    );
  }

  SizedBox get _padding => const SizedBox(width: 15);

  String _visibleDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return 'null';
    }

    // final visible = date.year == initDateTime.year &&
    //     date.month == initDateTime.month &&
    //     date.day == initDateTime.day;
    final visible = date.second != 0 && date.millisecond != 0;
    return visible ? date.toYYYYMMdd(context.l10n) : 'null';
  }

  /// Time側での変更が無い限り、初期値を表示
  String _visibleTime(BuildContext context, DateTime? time) {
    if (time == null) {
      return 'null';
    }

    final visible =
        time.second == initDateTime.second && time.millisecond == initDateTime.millisecond;

    return visible ? time.toHm(context.l10n) : 'null';
  }
}
