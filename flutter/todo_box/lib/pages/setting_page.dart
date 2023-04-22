import 'package:flutter/material.dart';
import 'package:todo_box/l10n/app_localizations.dart';
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
        title: Text(context.l10n.setting),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
            child: Text(
              context.l10n.notification,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 3.0, indent: 10.0, endIndent: 10.0),
          ListTile(
            leading: const Icon(Icons.event_repeat),
            title: Text(
              context.l10n.notificationDayOfWeek,
              style: const TextStyle(
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
            title: Text(
              context.l10n.notificationTime,
              style: const TextStyle(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 4.0),
            child: Text(
              context.l10n.keyboardInput,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 3.0, indent: 10.0, endIndent: 10.0),
          ListTile(
            leading: const Icon(Icons.draw_outlined),
            title: Text(context.l10n.continuousInputTodo),
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
