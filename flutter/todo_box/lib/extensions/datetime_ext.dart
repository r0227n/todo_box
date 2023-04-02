/// DateTimeの日付に関する拡張メソッド
extension DateX on DateTime {
  /// 日付のみを取得
  DateTime get date {
    if (year == 1972 && month == 1 && day == 1) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

    return DateTime(year, month, day);
  }

  /// 日付のみ比較し、結果を返す
  /// [0]: 同じ日付
  /// [1]: 比較対象の方が未来
  /// [-1]: 比較対象の方が過去
  int compareDateTo(DateTime other) {
    final source = DateTime(year, month, day);
    final target = DateTime(other.year, other.month, other.day);

    return source.compareTo(target);
  }

  /// 日付のみ比較し、結果を返す
  bool modifiedDate(DateTime other) {
    final source = DateTime(1972, 1, 1);
    final target = DateTime(other.year, other.month, other.day);

    return source != target;
  }

  /// [modifiedDate]のnull対応版s
  bool modifiedDateOrNull(DateTime? other) {
    if (other == null) {
      return false;
    }

    return modifiedDate(other);
  }
}

/// DateTimeの時間に関する拡張メソッド
extension TimeX on DateTime {
  /// 時間のみを取得
  DateTime get time => DateTime(1972, 1, 1, hour, minute, second, millisecond, microsecond);

  /// 時間のみ比較し、結果を返す
  /// [0]: 同じ時間
  /// [1]: 比較対象の方が未来
  /// [-1]: 比較対象の方が過去
  int compareTimeTo(DateTime other) {
    final target = DateTime(
        1972, 1, 1, other.hour, other.minute, other.second, other.millisecond, other.microsecond);

    return time.compareTo(target);
  }
}
