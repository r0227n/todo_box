import 'dart:convert' show jsonDecode;

extension SqlEncode on Object? {
  /// Convert to [String]
  /// If [null], return [null].
  String? tryParse() {
    if (this == null) {
      return null;
    }

    return toString();
  }

  /// Check Primary Key
  /// If there is no Primary Key, then error.
  String isKey() {
    if (this == null) {
      throw StateError('PrimaryKey does not exist.');
    }

    return toString();
  }

  /// Convert to [Bool]
  bool toBool() {
    final content = tryParse() ?? '';

    if (content == 'true') {
      return true;
    }

    return false;
  }

  /// Convert to [DateTime]
  /// If [null], return [null].
  DateTime? tryParseDateTime() {
    final content = tryParse() ?? '';
    return DateTime.tryParse(content);
  }

  /// Convert to [List<String>]
  List<String> toList() {
    final content = tryParse() ?? '';
    if (content.isEmpty) {
      return const <String>[];
    }

    return jsonDecode(content);
  }
}
