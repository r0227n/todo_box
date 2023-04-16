import 'package:flutter/material.dart';
import 'components/popup_day_of_week_button.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Divider(
            height: 3.0,
            indent: 10.0,
            endIndent: 10.0,
          ),
          const ListTile(
            leading: Icon(Icons.event_repeat),
            title: Text(
              'Notification days',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: PopupDayOfWeekButton(
              value: DayOfWeek.monday,
            ),
          ),
          const Divider(
            height: 3.0,
            indent: 10.0,
            endIndent: 10.0,
          ),
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
          const Divider(
            height: 3.0,
            indent: 10.0,
            endIndent: 10.0,
          ),
          ListTile(
            leading: const Icon(Icons.draw_outlined),
            title: const Text('Continue writing'),
            trailing: Switch(
              value: true, // TODO: ここに状態を持たせる
              onChanged: (bool value) {},
            ),
          ),
          const Spacer(),
          const Center(
            child: Text(
              'Version: 1.0.0', // TODO: ここにバージョンを持たせる
            ),
          ),
        ],
      ),
    );
  }
}
