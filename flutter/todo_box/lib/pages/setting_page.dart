import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_box/models/todo_box_metadata.dart';
import 'components/popup_day_of_week_button.dart';
import 'components/version_text.dart';
import '../../extensions/ext.dart';
import '../../controller/app_setting_controller.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSetting = ref.watch(appSettingControllerProvider);

    return appSetting.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('Error')),
      data: (setting) => _SettingPage(setting),
    );
  }
}

class _SettingPage extends HookWidget {
  const _SettingPage(this.metadata);

  final TodoBoxMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final notification = useState(metadata.notification);
    final continueWriting = useState(metadata.continueWriiting);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
            child: Text(
              'Default Notification',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 3.0, indent: 10.0, endIndent: 10.0),
          ListTile(
            leading: const Icon(Icons.event_repeat),
            title: const Text(
              'Notification days',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: PopupDayOfWeekButton(
              value: DayOfWeek.monday,
              onChaged: (dayOfWeek) {
                DateTime now = DateTime.now();
                print(now.weekday);
                now = now.changeDayOfWeek(dayOfWeek.number);
                print(now.weekday);
              },
            ),
          ),
          const Divider(height: 3.0, indent: 10.0, endIndent: 10.0),
          ListTile(
            leading: const Icon(Icons.edit_notifications_outlined),
            title: const Text(
              'Notification time',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: ActionChip(
              onPressed: () {},
              label: const Text(
                '10:00',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 4.0),
            child: Text(
              'Input',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 3.0, indent: 10.0, endIndent: 10.0),
          ListTile(
            leading: const Icon(Icons.draw_outlined),
            title: const Text('Continue writing'),
            trailing: Switch(
              value: true, // TODO: ここに状態を持たせる
              onChanged: (bool value) {},
            ),
          ),
          const Spacer(),
          const Center(child: VersionText()),
        ],
      ),
    );
  }
}
