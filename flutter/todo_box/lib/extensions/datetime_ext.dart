/// DateTimeの日付に関する拡張メソッド
extension DateX on DateTime {
  /// 日付のみを取得
  DateTime get date => DateTime(year, month, day);

  /// 日付のみ比較し、結果を返す
  /// [0]: 同じ日付
  /// [1]: 比較対象の方が未来
  /// [-1]: 比較対象の方が過去
  int compareDateTo(DateTime other) {
    final target = DateTime(other.year, other.month, other.day);

    return date.compareTo(target);
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
