import 'package:freezed_annotation/freezed_annotation.dart';

import '../types/notification_type.dart';

part 'notification_type.freezed.dart';
part 'notification_type.g.dart';

@freezed
class NotificationType with _$NotificationType {
  factory NotificationType({
    required int id,
    required NotificationSchedule schedule,
  }) = _NotificationType;

  factory NotificationType.fromJson(Map<String, dynamic> json) => _$NotificationTypeFromJson(json);
}
