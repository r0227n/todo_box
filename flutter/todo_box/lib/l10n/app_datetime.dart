import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

extension LocalString on DateTime {
  /// [AppLocalizations] ごとの時刻表記に変換
  String formatLocal(AppLocalizations localizations) {
    /// 日本語 / 日本
    if (isJp(localizations)) {
      // 時刻未選択
      if (hour == 0 && minute == 0 && second == 0 && millisecond == 0) {
        return DateFormat('MMMEd', 'ja').format(this);
      }

      return DateFormat('MMMEd', 'ja').format(this) + DateFormat('HH:mm').format(this);
    }

    ///　英語 / アメリカ
    return DateFormat('MMM, d, E, HH:mm').format(this);
  }

  String toMMMEd(AppLocalizations localizations) {
    if (isJp(localizations)) {
      return DateFormat.MMMEd('ja').format(this);
    }

    return DateFormat.MMMEd().format(this);
  }

  String toHHmm(AppLocalizations localizations) {
    return DateFormat('HH:mm').format(this);
  }

  bool isJp(AppLocalizations localizations) => localizations.localeName == 'ja';
}
