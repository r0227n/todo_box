import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

extension LocalString on DateTime {
  /// [AppLocalizations] ごとの時刻表記に変換
  String formatLocal(AppLocalizations localizations) {
    /// 日本語 / 日本
    if (localizations.localeName == 'ja') {
      // 時刻未選択
      if (hour == 0 && minute == 0 && second == 0 && millisecond == 0) {
        return DateFormat('MMMEd', 'ja').format(DateTime.now());
      }

      return DateFormat('MMMEd', 'ja').format(DateTime.now()) +
          DateFormat('HH:mm').format(DateTime.now());
    }

    ///　英語 / アメリカ
    return DateFormat('MMM, d, E, HH:mm').format(this);
  }
}
