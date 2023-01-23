import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;

final localNotificationProvider =
    StateNotifierProvider<LocalNotificationController, FlutterLocalNotificationsPlugin>(
        (ref) => LocalNotificationController());

class LocalNotificationController extends StateNotifier<FlutterLocalNotificationsPlugin> {
  LocalNotificationController() : super(FlutterLocalNotificationsPlugin()) {
    _initialize();
  }

  Future<void> _initialize() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);

    await AsyncValue.guard(() async => state.initialize(initSettings));
  }

  Future<void> addNotification(String title, String body, int endTime, int id,
      {required String channel}) async {
    tz.initializeTimeZones();
    final scheduleTime = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);

    final androidDetail = AndroidNotificationDetails(
      channel, // channel Id
      channel, // channel Name
    );

    const iosDetail = DarwinNotificationDetails();

    final noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

    await state.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      noticeDetail,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<List<PendingNotificationRequest>> showPendingNotifications() async {
    return await state.pendingNotificationRequests();
  }
}
