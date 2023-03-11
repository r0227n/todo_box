import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;

final localNotificationPluguinProvider =
    Provider<FlutterLocalNotificationsPlugin>((_) => throw UnimplementedError());

final localNotificationProvider =
    StateNotifierProvider<LocalNotificationController, FlutterLocalNotificationsPlugin>(
  (ref) => LocalNotificationController(ref.watch(localNotificationPluguinProvider)),
);

class NotificationInitilizer {
  NotificationInitilizer({this.foregroundResponse}) {
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

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");
  final plugin = FlutterLocalNotificationsPlugin();

  /// アプリが起動中、通知をタップしたときに遷移する画面
  final Widget? foregroundResponse;

  /// アプリが起動中、通知をタップしたときの処理
  void _notificationTapForeground(NotificationResponse notificationResponse) {
    if (navigatorKey.currentContext != null && foregroundResponse != null) {
      Navigator.push(
        navigatorKey.currentState!.context,
        MaterialPageRoute(
          builder: (_) => foregroundResponse!,
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
  // // 現在のウィジェットツリーのBuildContextを取得する
  // final BuildContext? context =
  //     WidgetsBinding.instance.getFlutterEngine?.binding?.buildOwner?.rootBuildContext;

  // handle action

  // if (key.currentState?.context == null) {
  //   return;
  // }
  // // TODO: いい感じにTODOの詳細画面に遷移するようにする
}

class LocalNotificationController extends StateNotifier<FlutterLocalNotificationsPlugin> {
  LocalNotificationController(this.pluguin) : super(pluguin);

  final FlutterLocalNotificationsPlugin pluguin;

  Future<void> addNotification(String title, String body, DateTime endTime, int id,
      {required String channel}) async {
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
