import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
      error: (error, stack) => const Center(child: Text('Error')), // TODO: エラー画面を作成し、そこに遷移する
      data: (_) => const _SettingDataPage(),
    );
  }
}

class _SettingDataPage extends ConsumerWidget {
  const _SettingDataPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = ref.watch(appSettingControllerProvider);

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
              value: setting.asData?.value.notification.dayOfWeek ?? DayOfWeek.monday,
              onChaged: (dayOfWeek) {
                final oldState = setting.asData?.value.notification;
                final newState = oldState?.changeDayOfWeek(dayOfWeek.number);
                ref.read(appSettingControllerProvider.notifier).modified(notification: newState);
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
              onPressed: () {
                final initTime =
                    TimeOfDay.fromDateTime(setting.asData?.value.notification ?? DateTime.now());
                showTimePicker(context: context, initialTime: initTime).then((time) {
                  if (time == null) {
                    return;
                  }
                  final oldState = setting.asData?.value.notification ?? DateTime.now();
                  final newState = DateTime(
                    oldState.year,
                    oldState.month,
                    oldState.day,
                    time.hour,
                    time.minute,
                    oldState.second,
                  );
                  ref.read(appSettingControllerProvider.notifier).modified(notification: newState);
                });
              },
              label: Text(
                setting.asData?.value.notification == null
                    ? '00:00'
                    : '${setting.asData?.value.notification.hour}:${setting.asData?.value.notification.minute}',
                style: const TextStyle(
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
              value: setting.asData?.value.continueWriiting ?? false,
              onChanged: (bool toggle) async {
                ref.read(appSettingControllerProvider.notifier).modified(continueWriiting: toggle);
              },
            ),
          ),
          const Spacer(),
          const Center(child: VersionText()),
        ],
      ),
    );
  }
}
