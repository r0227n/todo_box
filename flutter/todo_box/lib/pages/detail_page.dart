import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/todo.dart';

class DetailPage extends StatefulWidget {
  const DetailPage(this.todo, {super.key});

  final Todo todo;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late String _tabelLabel;
  DateTime? _dateTime;
  late final TextEditingController txtController;

  @override
  void initState() {
    super.initState();
    _tabelLabel = widget.todo.table;
    if (widget.todo.date != null) {
      _dateTime = widget.todo.date;
    }

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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outlined),
          ),
          const SizedBox(width: 12.0),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: Row(
              children: <Widget>[
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      size: 24.0,
                    ),
                    label: Text(_tabelLabel),
                  ),
                ),
                const Spacer(),
              ],
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
              if (date == null) {
                return;
              }

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
          )
        ],
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
