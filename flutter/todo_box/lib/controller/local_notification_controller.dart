import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;
import '../models/todo.dart';
import '../pages/detail_page.dart';

final localNotificationPluguinProvider =
    Provider<FlutterLocalNotificationsPlugin>((_) => throw UnimplementedError());

final localNotificationProvider =
    StateNotifierProvider<LocalNotificationController, FlutterLocalNotificationsPlugin>(
  (ref) => LocalNotificationController(ref.watch(localNotificationPluguinProvider)),
);

class NotificationInitilizer {
  NotificationInitilizer() {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);

    plugin
        .initialize(
          initSettings,
          onDidReceiveNotificationResponse: _notificationTapForeground,
          onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
        )
        .catchError(
            (e) => throw FlutterError('FlutterLocalNotificationsPlugin initialize error: $e'));
  }

  // [FlutterLocalNotificationsPlugin]'s [GlobalKey]
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

  // [FlutterLocalNotificationsPlugin] instance
  final plugin = FlutterLocalNotificationsPlugin();

  /// アプリが起動中、通知をタップしたときの処理
  void _notificationTapForeground(NotificationResponse notificationResponse) {
    if (notificationResponse.payload == null) {
      throw StateError('payload is null');
    }

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => DetailPage(Todo.fromString(notificationResponse.payload ?? '')),
        ),
      );
    }
  }
}

/// バックグラウンドで通知をタップしたときの処理
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('onDidReceiveBackgroundNotificationResponse');
  debugPrint('notificationResponse');
}

class LocalNotificationController extends StateNotifier<FlutterLocalNotificationsPlugin> {
  LocalNotificationController(this.pluguin) : super(pluguin);

  final FlutterLocalNotificationsPlugin pluguin;

  Future<void> addNotification(
    String title,
    String body,
    DateTime endTime,
    int id, {
    required String channel,
    Map<String, dynamic>? payload,
  }) async {
    tz.initializeTimeZones();

    final scheduleTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime.millisecondsSinceEpoch);

    final androidDetail = AndroidNotificationDetails(
      channel, // channel Id
      channel, // channel Name
    );

    const iosDetail = DarwinNotificationDetails();

    final noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

    AsyncValue.guard(
      () async => await state.zonedSchedule(
        id,
        title,
        body,
        // scheduleTime,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        noticeDetail,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        payload: payload.toString(),
      ),
    );
  }

  /// 通知をタップし、アプリを起動した時の詳細を取得する
  /// 通知をタップし、アプリを起動していない場合はnullを返す
  Future<NotificationResponse?> launchNotificationResponse() async {
    final details =
        await AsyncValue.guard(() async => await state.getNotificationAppLaunchDetails());
    return details.asData?.value?.notificationResponse;
  }

  Future<List<PendingNotificationRequest>> showPendingNotifications() async {
    return await state.pendingNotificationRequests();
  }
}
