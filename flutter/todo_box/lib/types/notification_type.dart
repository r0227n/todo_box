import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show DateTimeComponents;

/// 通知のスケジュール
enum NotificationSchedule {
  none, // 通知しない
  dailly, // 毎日
  weekly, // 毎週
  monthly; // 毎月

  /// [NotificationSchedule]を[DateTimeComponents]に変換する
  DateTimeComponents? toDateTimeComponents() {
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
      default:
        return null;
    }
  }
}
