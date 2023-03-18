import 'dart:math';

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

/// 通知のスケジュール
enum NotificationSchedule {
  dailly, // 毎日
  weekly, // 毎週
  monthly; // 毎月

  /// [NotificationSchedule]を[DateTimeComponents]に変換する
  DateTimeComponents toDateTimeComponents() {
    switch (this) {
      case NotificationSchedule.dailly:
        // 毎日同じ時間に通知を出す
        return DateTimeComponents.time;
      case NotificationSchedule.weekly:
        // 毎週同じ曜日と時間に通知を出す
        return DateTimeComponents.dayOfWeekAndTime;
      case NotificationSchedule.monthly:
        // 毎月同じ日と時間に通知を出す
        return DateTimeComponents.dayOfMonthAndTime;
    }
  }
}

class LocalNotificationController extends StateNotifier<FlutterLocalNotificationsPlugin> {
  LocalNotificationController(this.pluguin) : super(pluguin);

  final FlutterLocalNotificationsPlugin pluguin;

  /// 既存に登録されている通知のidを取得する
  Future<List<int>> get existingIds async {
    final pendings = await getPendingNotifications();
    final actives = await getActiveNotifications();

    return [...?pendings?.map((e) => e.id), ...?actives?.map((e) => e.id)];
  }

  // 0 ~ 2147483647の乱数を生成する
  // 32bit = -2147483647 ~ 2147483647
  int get randomId => Random().nextInt(2147483647);

  /// create a [zonedSchedule]'s id
  /// 既に存在するidは生成しない
  Future<int> get scheduleId async {
    final ids = await existingIds;

    do {
      final id = randomId;
      if (!ids.contains(id)) {
        return id;
      }
    } while (true);
  }

  /// 通知を登録する
  /// [id]は32bitの整数である必要がある(flutter_local_notificationの仕様)
  Future<int> addNotification(
    String title,
    String body,
    DateTime endTime, {
    int? id,
    required String channel,
    Map<String, dynamic>? payload,
    NotificationSchedule? schedule,
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

    final zoneScheduleId = id ?? await scheduleId;

    await AsyncValue.guard(() async => await state.zonedSchedule(
          zoneScheduleId,
          title,
          body,
          scheduleTime,
          noticeDetail,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true,
          payload: payload.toString(),
          matchDateTimeComponents: schedule?.toDateTimeComponents(),
        )).then((e) {
      if (e.hasError) {
        throw e.asError?.value;
      }
    });

    return zoneScheduleId;
  }

  /// 通知をキャンセルする
  Future<bool> cancelNotification(int id) async {
    final result = await AsyncValue.guard(() async => await state.cancel(id));
    return result.hasValue;
  }

  /// 通知をタップし、アプリを起動した時の詳細を取得する
  /// 通知をタップし、アプリを起動していない場合はnullを返す
  Future<NotificationResponse?> launchNotificationResponse() async {
    final details =
        await AsyncValue.guard(() async => await state.getNotificationAppLaunchDetails());
    return details.asData?.value?.notificationResponse;
  }

  /// 指定時刻前の通知を取得(予約された通知を取得する)
  Future<List<PendingNotificationRequest>?> getPendingNotifications() async {
    final pendings = await AsyncValue.guard(() async => await state.pendingNotificationRequests());
    return pendings.maybeWhen(
      orElse: () => null,
      data: (notifications) => notifications.isEmpty ? null : notifications,
    );
  }

  /// 指定時刻を過ぎた通知を取得(通知された通知を取得する)
  Future<List<ActiveNotification>?> getActiveNotifications() async {
    final actives = await AsyncValue.guard(() async => await state.getActiveNotifications());
    return actives.maybeWhen(
      orElse: () => null,
      data: (notifications) => notifications.isEmpty ? null : notifications,
    );
  }
}
