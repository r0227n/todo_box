import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_box/l10n/app_localizations.dart';
import 'mod_tool.dart';
import 'mod_button.dart';
import 'mod_tool_picker.dart';
import '../../detail_image.dart';
import '../../../types/notification_type.dart';
import '../../../extensions/string_ext.dart';

class KeyboardMods extends StatefulWidget {
  const KeyboardMods({
    this.visibleAppBar = false,
    required this.visibleKeyboard,
    this.appBarTitle,
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

  /// Widget displayed above the keyboard
  final List<ModButton> mods;

  final List<ModActionChip> chips;
  final ModActionChip selectedChip;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  final bool visibleAppBar;

  final bool visibleKeyboard;

  final Widget? appBarTitle;

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
  late final FocusNode _node;

  late List<ModButton> modButtons;
  late final TextEditingController _controller;

  final ImagePicker _picker = ImagePicker();
  final List<File> _pickFiles = <File>[];

  late ModActionChip _selectedChip;

  NotificationSchedule _notificationSchedule = NotificationSchedule.none;

  bool _visibleToolBar = false;
  Widget? _modToolWidgetState;

  late final DateTime _now;
  final ValueNotifier<DateTime?> _selectDateTime = ValueNotifier<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    _node = FocusNode(debugLabel: 'KeyboardMods');

    _initModButtons;

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
    _initModButtons;

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

  /// [ModButton]'s initialize
  void get _initModButtons {
    int count = 0;
    modButtons = widget.mods
        .map((e) => e.copyWith(
            modIndex: count++, select: false, callback: _updateState, onDeleted: _deleteAction))
        .toList();
    _selectDateTime.value = null;
    _modToolWidgetState = null;
  }

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
                modButtons = modButtons.map((e) {
                  if (e.modIndex != index) {
                    return e;
                  }

                  return e.copyWith(chip: chip);
                }).toList();
                _selectedChip = chip;
                _visibleToolBar = !_visibleToolBar;
              });
            },
          );
        });

        break;
      case ModCategory.time:
        setState(() {
          _modToolWidgetState = ValueListenableBuilder(
            valueListenable: _selectDateTime,
            builder: (context, value, child) {
              return _ModActionDateTime(
                initDateTime: value ?? _now,
                dateTime: value,
                schedule: _notificationSchedule,
                focusNode: _node,
                onDatePicker: (date) {
                  setState(() {
                    _selectDateTime.value = date;
                    modButtons = modButtons.map((e) {
                      if (e.modIndex != index) {
                        return e;
                      }

                      return e.copyWith(chip: e.chip?.copyWith(dateTime: date));
                    }).toList();
                  });
                },
                onTimePicker: (time) {
                  setState(() {
                    _selectDateTime.value = time;
                    modButtons = modButtons.map((e) {
                      if (e.modIndex != index) {
                        return e;
                      }

                      return e.copyWith(chip: e.chip?.copyWith(dateTime: time));
                    }).toList();
                  });
                },
                onSelectRepeat: (reqeat) {
                  if (reqeat != null) {
                    setState(() {
                      _notificationSchedule = reqeat;
                    });
                  }
                },
              );
            },
          );
        });

        break;
      case ModCategory.image:
        setState(() {
          _modToolWidgetState = ModToolPicker(
            item: [
              PickerItem(
                onPressed: () {
                  // ModButtonがキーボードに隠れるのを防ぐため、一時的な対応策として実施
                  FocusScope.of(context).unfocus();

                  _picker.pickImage(source: ImageSource.gallery).then((pickedFile) {
                    // ModButtonがキーボードに隠れるのを防ぐため、一時的な対応策として実施
                    FocusScope.of(context).requestFocus(_node);

                    if (pickedFile == null) {
                      return;
                    }

                    setState(() {
                      _pickFiles.add(File(pickedFile.path));
                    });
                  });
                },
                icon: const Icon(
                  Icons.abc,
                  size: 36.0,
                ),
                title: 'findDateTime',
              ),
            ],
          );
        });
        break;
      case ModCategory.action:
        // TODO: Handle this case.
        break;
    }

    // [ModButton]のStateを更新
    setState(() {
      _visibleToolBar = !_visibleToolBar;
      modButtons = modButtons.map((e) {
        // 選択された[ModButton]のStateを更新
        if (e.modIndex == index) {
          // oldStateとnewStateで異なる[ModButton]を選択された場合、[_modToolWidgetState]を表示
          if (_visibleToolBar == e.select) {
            _visibleToolBar = true;
            return e.copyWith(select: true);
          }

          // oldStateとnewStateで同じ[ModButton]を選択された場合、[_modToolWidgetState]を非表示
          return e.copyWith(select: _visibleToolBar);
        }

        // 選択されていない[ModButton]を非選択の状態にする
        return e.copyWith(select: false);
      }).toList();
    });
  }

  void _deleteAction() {
    final findDateTime = modButtons.where((element) => element.chip?.dateTime != null).toList();
    if (findDateTime.isNotEmpty) {
      if (findDateTime.length != 1) {
        throw FlutterError('Error KeyboardMods State');
      }
      final index = modButtons.indexOf(findDateTime.first);
      final button = modButtons[index];
      setState(() {
        modButtons[index] = button.copyWith(
          select: _visibleToolBar,
          chip: button.chip?.copyWith(dateTime: null),
        );
      });
    }
    _selectDateTime.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.visibleAppBar
          ? null
          : AppBar(
              title: widget.appBarTitle,
              actions: [
                SingleChildScrollView(
                  child: SizedBox(
                    height: kBottomNavigationBarHeight,
                    width: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pickFiles.length,
                      itemBuilder: (context, index) {
                        return Material(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailImage(
                                    files: _pickFiles,
                                    index: _pickFiles.indexOf(_pickFiles[index]),
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

                                final idx = _pickFiles.indexOf(_pickFiles[index]);
                                setState(() {
                                  _pickFiles[idx] = File(newState.path);
                                });
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Image.file(_pickFiles[index]),
                            ),
                          ),
                        );
                      },
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
                    setState(() {
                      _pickFiles.clear();
                      modButtons = modButtons.map((e) {
                        if (e.select) {
                          return e.copyWith(select: false);
                        }
                        return e;
                      }).toList();
                    });
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
                        final submittedMenu = _selectedChip.label ?? widget.selectedChip.label;
                        if (submittedMenu == null) {
                          throw StateError('The State of Menu does not exist.');
                        }

                        widget.onSubmitted!(ModInputValue(
                          text: text,
                          selectMenu: submittedMenu,
                          date: _selectDateTime.value,
                          images: _pickFiles,
                          schedule: _notificationSchedule,
                        ));

                        _pickFiles.clear();
                      }
                      _controller.clear();
                    },
                    onEditingComplete: () {
                      // 呼び出し元で[visibleKeyboard]がEnterキーを押した場合、
                      // true: キーボードを表示し続ける
                      // false: キーボードを閉じる
                      if (widget.visibleKeyboard) {
                        _node.requestFocus();
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
              if (_node.hasFocus && _visibleToolBar && _modToolWidgetState != null)
                SizedBox(
                  width: double.infinity,
                  height: 75,
                  child: _modToolWidgetState,
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
}

class ModInputValue {
  const ModInputValue({
    required this.text,
    required this.selectMenu,
    required this.date,
    required this.images,
    required this.schedule,
  });

  /// 入力されたテキスト
  final String text;

  /// 選択されたメニュー
  final String selectMenu;

  /// 期限
  final DateTime? date;

  /// 画像ファイル
  final List<File> images;

  /// 通知スケジュール
  final NotificationSchedule schedule;
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
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (final chip in chips)
          ActionChip(
            shape: const StadiumBorder(side: BorderSide()),
            avatar: FittedBox(child: chip.icon),
            label: Text(chip.label ?? chip.dateTime?.formatLocal(context.l10n) ?? ''),
            onPressed: () => onPressed(chip),
          ),
      ],
    );
  }
}

class _ModActionDateTime extends StatelessWidget {
  const _ModActionDateTime({
    required this.initDateTime,
    this.dateTime,
    required this.schedule,
    required this.focusNode,
    required this.onDatePicker,
    required this.onTimePicker,
    required this.onSelectRepeat,
  });

  final DateTime initDateTime;
  final DateTime? dateTime;
  final NotificationSchedule schedule;
  final FocusNode focusNode;
  final ValueChanged<DateTime> onDatePicker;
  final ValueChanged<DateTime> onTimePicker;
  final ValueChanged<NotificationSchedule?> onSelectRepeat;

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
                  initialDate: dateTime ?? DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2040),
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
                ));
              },
              child: Text(dateTime?.toYYYYMMdd(context.l10n) ?? 'Date'),
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
                ));

                focusNode.requestFocus();
              },
              child: Text(dateTime?.toHHmm(context.l10n) ?? 'Time'),
            ),
          ),
          _padding,
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
            ),
            onPressed: () {
              showDialog<NotificationSchedule>(
                context: context,
                builder: (childContext) {
                  return SimpleDialog(
                    title: const Text("Title"),
                    insetPadding: const EdgeInsets.all(15.0),
                    children: <Widget>[
                      for (final schedule in NotificationSchedule.values)
                        ListTile(
                          title: Text(schedule.name.capitalize),
                          trailing: schedule == this.schedule ? const Icon(Icons.check) : null,
                          onTap: () {
                            Navigator.pop(childContext, schedule);
                          },
                        ),
                    ],
                  );
                },
              ).then((repeat) => onSelectRepeat(repeat));
            },
            icon: const Icon(Icons.repeat),
            label: (schedule == NotificationSchedule.none)
                ? const SizedBox.shrink()
                : Text(schedule.name.capitalize),
          ),
          _padding,
        ],
      ),
    );
  }

  /// ボタン間の余白
  SizedBox get _padding => const SizedBox(width: 15);
}
