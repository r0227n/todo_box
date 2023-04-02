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

  String toYYYYMMdd(AppLocalizations localizations) {
    if (isJp(localizations)) {
      return DateFormat('yyyy/MM/dd').format(this);
    }

    return DateFormat('dd/MM/yyyy').format(this);
  }

  String toHm(AppLocalizations localizations) {
    return DateFormat.Hm().format(this);
  }

  String? toMMMEd(AppLocalizations localizations) {
    if (year == 1972 && month == 1 && day == 1) {
      return null;
    } else if (isJp(localizations)) {
      return DateFormat.MMMEd('ja').format(this);
    }

    return DateFormat.yMd().format(this);
  }

  String? toHHmm(AppLocalizations localizations) {
    if (hour == 0 && minute == 0 && second == 0 && millisecond == 0) {
      return null;
    }

    return DateFormat('HH:mm').format(this);
  }

  bool isJp(AppLocalizations localizations) => localizations.localeName == 'ja';
}
