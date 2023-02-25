import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_box/controller/todo_controller.dart';
import 'components/emoji_text.dart';
import '../provider/tables_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../models/table.dart' as todo;
import 'detail_image.dart';

class DetailPage extends StatefulWidget {
  const DetailPage(this.todo, {super.key});

  final Todo todo;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late String _tabelLabel;
  DateTime? _dateTime;
  late final List<Uint8List> _images;
  late final TextEditingController txtController;

  @override
  void initState() {
    super.initState();
    _tabelLabel = widget.todo.table;
    if (widget.todo.date != null) {
      _dateTime = widget.todo.date;
    }
    _images = widget.todo.assets.whereType<String>().map((e) => base64Decode(e)).toList();

    txtController = TextEditingController(text: widget.todo.title);
  }

  @override
  void dispose() {
    txtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Consumer(
            builder: (context, ref, _) => IconButton(
              onPressed: () async {
                final todoCtrl = ref.read(todoControllerProvider.notifier);
                todoCtrl.remove(widget.todo);
                // TODO: 設定でホーム画面に戻るかどうか選択できるようにする
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outlined),
            ),
          ),
          const SizedBox(width: 12.0),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 4.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextButton.icon(
                onPressed: () async {
                  final table = await showModalBottomSheet<todo.Table>(
                    context: context,
                    builder: (BuildContext context) {
                      return Consumer(builder: (context, ref, _) {
                        final tables = ref.watch(tablesProvider);
                        return SizedBox(
                          height: 90.0 + 40.0 * tables.length,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0.0, 14.0, 0.0, 10.0),
                                child: Text('Move todo to'),
                              ),
                              for (final table in tables)
                                TextButton.icon(
                                  icon: EmojiText(table.icon),
                                  label: Text(table.title),
                                  onPressed: () => Navigator.pop(context, table),
                                ),
                            ],
                          ),
                        );
                      });
                    },
                  );

                  if (table == null) {
                    return;
                  }

                  setState(() {
                    _tabelLabel = table.title;
                  });
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 24.0,
                ),
                label: Text(_tabelLabel),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 4.0),
            child: TextField(
              maxLines: null,
              controller: txtController,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          _DatePicker(
            null,
            _dateTime?.toMMMEd(context.l10n) ?? '日時を追加',
            onSelect: (date) {
              final now = DateTime.now();
              setState(() {
                _dateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  _dateTime?.hour ?? now.hour,
                  _dateTime?.minute ?? now.minute,
                );
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(_dateTime?.toHHmm(context.l10n) ?? '時間を追加'),
            onTap: () async {
              final selectedTime = await showTimePicker(
                initialTime: TimeOfDay.now(),
                context: context,
              );
              if (selectedTime != null) {
                final now = DateTime.now();

                setState(() {
                  _dateTime = DateTime(
                    _dateTime?.year ?? now.year,
                    _dateTime?.month ?? now.month,
                    _dateTime?.day ?? now.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Images'),
            trailing: IconButton(
              onPressed: () {
                // TODO: ImagePicker(カメラorフォルダ)選択UI実装
              },
              icon: const Icon(Icons.add_photo_alternate),
              tooltip: 'Add Image',
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: GridView.builder(
                    physics: const ScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5.0,
                    ),
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 4.0),
                    itemCount: _images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        color: Theme.of(context).colorScheme.onPrimary,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailImage(
                                assets: _images,
                                index: index,
                                onDelete: (value) {
                                  setState(() {
                                    _images.remove(value);
                                  });
                                },
                              ),
                            ),
                          ),
                          child: Image.memory(_images[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, _) => FloatingActionButton.extended(
          onPressed: () {
            final todoCtrl = ref.read(todoControllerProvider.notifier);
            todoCtrl.toggle(widget.todo);
            // TODO: 設定でホーム画面に戻るかどうか選択できるようにする
            Navigator.pop(context);
          },
          label: widget.todo.done ? const Text('Uncomplete') : const Text('Complete'),
          icon: widget.todo.done ? const Icon(Icons.restore_page) : const Icon(Icons.done),
        ),
      ),
    );
  }
}

class _DatePicker extends StatefulWidget {
  const _DatePicker(
    this.restorationId,
    this.data, {
    required this.onSelect,
  });

  final String? restorationId;
  final String data;
  final ValueChanged<DateTime>? onSelect;

  @override
  State<_DatePicker> createState() => __DatePickerState();
}

class __DatePickerState extends State<_DatePicker> with RestorationMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime(2021, 7, 25));
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  static Route<DateTime> _datePickerRoute(
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
          firstDate: DateTime(2021),
          lastDate: DateTime(2022),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
      });
      if (widget.onSelect is ValueChanged<DateTime>) {
        widget.onSelect!(newSelectedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        leading: const Icon(Icons.event_available),
        title: Text(widget.data),
        onTap: () => _restorableDatePickerRouteFuture.present(),
      ),
    );
  }
}
