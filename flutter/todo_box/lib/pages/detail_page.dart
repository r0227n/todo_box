import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;
import 'dart:convert' show base64Encode, base64Decode;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'detail_image.dart';
import 'components/emoji_text.dart';
import '../extensions/ext.dart';
import '../types/notification_type.dart';
import '../controller/todo_controller.dart';
import '../provider/tables_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../models/table.dart' as sql;

class DetailPage extends HookConsumerWidget {
  DetailPage(this.todo, {super.key});

  final Todo todo;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableLabel = useState<String>(todo.table);
    final dateTime = useState<DateTime?>(todo.date);
    final images = useState<List<Uint8List>>(
        todo.assets.isNotEmpty ? todo.assets.map((e) => base64Decode(e)).toList() : []);
    final schedule = useState<NotificationSchedule>(todo.notification.first.schedule);
    final txtController = useTextEditingController(text: todo.title);

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                final todoCtrl = ref.read(todoControllerProvider(todo.table).notifier);
                todoCtrl.remove(todo);
                // TODO: 設定でホーム画面に戻るかどうか選択できるようにする
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outlined),
            ),
            const SizedBox(width: 12.0),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onDoubleTap: null,
          onHorizontalDragUpdate: (details) {
            if (details.localPosition.dx < 45.0) {
              // 画面右端をスワイプした場合は戻る

              final popValue = _popTodo(tableLabel.value, txtController.text, dateTime.value,
                  schedule.value, images.value);
              Navigator.pop(context, popValue);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 4.0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextButton.icon(
                    onPressed: () async {
                      showModalBottomSheet<sql.Table>(
                        context: context,
                        builder: (BuildContext context) {
                          final tables = ref.read(tablesProvider);

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
                        },
                      ).then((table) {
                        if (table == null) {
                          return;
                        }

                        tableLabel.value = table.title;
                      });
                    },
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      size: 24.0,
                    ),
                    label: Text(tableLabel.value),
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
              ListTile(
                leading: const Icon(Icons.event_available),
                title: Text(dateTime.value?.toMMMEd(context.l10n) ?? '日時を追加'),
                trailing: todo.date?.modifiedDateOrNull(dateTime.value) ?? false
                    ? IconButton(
                        onPressed: () => dateTime.value = null,
                        icon: const Icon(Icons.cancel_outlined),
                      )
                    : null,
                onTap: () => showDatePicker(
                  context: context,
                  initialDate: dateTime.value?.date ?? DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2040),
                ).then(
                  (date) {
                    if (date != null) {
                      final now = DateTime.now();
                      dateTime.value = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        dateTime.value?.hour ?? now.hour,
                        dateTime.value?.minute ?? now.minute,
                      );
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(dateTime.value?.toHHmm(context.l10n) ?? '時間を追加'),
                onTap: () async {
                  final now = DateTime.now();
                  final hour = dateTime.value?.hour ?? now.hour;
                  final minute = dateTime.value?.minute ?? now.minute;
                  showTimePicker(
                    initialTime: TimeOfDay(hour: hour, minute: minute),
                    context: context,
                  ).then((selectedTime) {
                    if (selectedTime != null) {
                      final now = DateTime.now();

                      dateTime.value = DateTime(
                        dateTime.value?.year ?? now.year,
                        dateTime.value?.month ?? now.month,
                        dateTime.value?.day ?? now.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    }
                  });
                },
              ),
              if (dateTime.value != null)
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('Repeat'),
                  trailing: Text(
                    schedule.value.name.capitalize,
                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                  ),
                  onTap: () => _showNotificationSchedule(context, schedule.value).then((repeat) {
                    if (repeat != null) {
                      schedule.value = repeat;
                    }
                  }),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Images'),
                trailing: IconButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    builder: (builder) {
                      return Container(
                        height: 200.0,
                        padding: const EdgeInsets.all(30.0),
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            TextButton.icon(
                              onPressed: () => _getImagePicker(ImageSource.camera, images),
                              icon: const Icon(Icons.add_a_photo),
                              label: const SizedBox(
                                width: 100,
                                child: Text(
                                  'Take Photo',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _getImagePicker(ImageSource.gallery, images),
                              icon: const Icon(Icons.photo_library),
                              label: const SizedBox(
                                width: 100,
                                child: Text(
                                  'Select Library',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
                        itemCount: images.value.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Theme.of(context).colorScheme.onPrimary,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailImage(
                                    assets: images.value,
                                    index: index,
                                    onDelete: (data) {
                                      final list = List<Uint8List>.from(images.value);
                                      list.remove(data);
                                      images.value = list;
                                    },
                                  ),
                                ),
                              ),
                              child: Image.memory(images.value[index]),
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
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final todoCtrl = ref.read(todoControllerProvider(todo.table).notifier);
            todoCtrl.toggle(todo);
            // TODO: 設定でホーム画面に戻るかどうか選択できるようにする
            Navigator.pop(context, null);
          },
          label: todo.done ? const Text('Uncomplete') : const Text('Complete'),
          icon: todo.done ? const Icon(Icons.restore_page) : const Icon(Icons.done),
        ),
      ),
      onWillPop: () async {
        final popValue = _popTodo(
            tableLabel.value, txtController.text, dateTime.value, schedule.value, images.value);

        Navigator.pop(context, popValue);
        return true;
      },
    );
  }

  Todo? _popTodo(
    String table,
    String title,
    DateTime? dateTime,
    NotificationSchedule schedule,
    List<Uint8List> images,
  ) {
    // 日時指定が[null]の場合、通知を[none]にする
    if (dateTime == null) {
      schedule = NotificationSchedule.none;
    }

    // スワイプ方向が左の場合
    final editTodo = todo.copyWith(
      table: table,
      title: title,
      date: dateTime,
      notification: todo.notification.map((e) => e.copyWith(schedule: schedule)).toList(),
      assets: images.map((e) => base64Encode(e)).toList(),
    );
    return editTodo == todo ? null : editTodo;
  }

  /// [NotificationSchedule]の選択肢UIを[SimpleDialog]で表示する
  Future<NotificationSchedule?> _showNotificationSchedule(
      BuildContext context, NotificationSchedule notification) async {
    return showDialog<NotificationSchedule>(
      context: context,
      builder: (childContext) {
        return SimpleDialog(
          title: const Text("Repeat"),
          insetPadding: const EdgeInsets.all(15.0),
          children: <Widget>[
            for (final schedule in NotificationSchedule.values)
              ListTile(
                title: Text(schedule.name.capitalize),
                trailing: schedule == notification ? const Icon(Icons.check) : null,
                onTap: () {
                  Navigator.pop(childContext, schedule);
                },
              ),
          ],
        );
      },
    );
  }

  /// [ImagePicker]で取得した画像をUI描画に反映させる
  void _getImagePicker(ImageSource source, ValueNotifier<List<Uint8List>> images) {
    _picker.pickImage(source: source).then((img) {
      if (img == null) {
        return;
      }

      images.value = [...images.value, File(img.path).readAsBytesSync()];
    });
  }
}
