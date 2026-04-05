extension StringDigitsX on String {
  /// Returns true if the string contains only digits (Western, Arabic-Indic, Eastern Arabic).
  bool get isAllDigits => RegExp(r'^[0-9٠-٩۰-۹]+$').hasMatch(this);

  /// Converts Arabic-Indic and Eastern Arabic digits into Western digits.
  ///
  /// It also strips any non-digit characters.
  String normalizeDigits() {
    const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
    const easternArabic = '۰۱۲۳۴۵۶۷۸۹';

    final buf = StringBuffer();
    for (final r in runes) {
      final ch = String.fromCharCode(r);

      final ai = arabicIndic.indexOf(ch);
      if (ai != -1) {
        buf.write(ai);
        continue;
      }

      final ea = easternArabic.indexOf(ch);
      if (ea != -1) {
        buf.write(ea);
        continue;
      }

      // Western digits.
      final code = ch.codeUnitAt(0);
      if (code >= 48 && code <= 57) {
        buf.write(ch);
      }
    }

    return buf.toString();
  }
}
