import 'app_localizations.dart';

extension Timezon on AppLocalizations {
  /// 標準時名
  String get timezoneId {
    switch (localeName) {
      case 'ja':
        return 'Asia/Tokyo';
      default:
        //　アメリカ東部標準時
        return 'America/New_York';
    }
  }
}
