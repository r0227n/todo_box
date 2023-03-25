extension StringExt on String {
  /// 文字列の先頭のみ大文字にする
  String get capitalize => substring(0, 1).toUpperCase() + substring(1);
}
