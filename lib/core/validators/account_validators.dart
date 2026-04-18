class AccountValidators {
  static final RegExp _emailRx = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? requiredText(String? v, {String message = 'This field is required'}) {
    if (v == null || v.trim().isEmpty) return message;
    return null;
  }

  static String? name(String? v) {
    return requiredText(v, message: 'This field is required');
  }

  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required';
    if (!_emailRx.hasMatch(s)) return 'Enter a valid email address';
    return null;
  }

  static String? egyptPhone(String? v) {
    return requiredText(v, message: 'Phone number is required');
  }

  static String? nationalId(String? v) {
    return requiredText(v, message: 'National ID is required');
  }

  static String? password(String? v) {
    if ((v ?? '').isEmpty) return 'Password is required';
    return null;
  }

  static String? license(String? v) {
    return requiredText(v, message: 'Medical license is required');
  }

  static DateTime? parseYMD({required String y, required String m, required String d}) {
    final yy = int.tryParse(y.trim());
    final mm = int.tryParse(m.trim());
    final dd = int.tryParse(d.trim());
    if (yy == null || mm == null || dd == null) return null;
    try {
      final dt = DateTime(yy, mm, dd);
      if (dt.year != yy || dt.month != mm || dt.day != dd) return null;
      return dt;
    } catch (_) {
      return null;
    }
  }

  static String? birthDateYMD({required String y, required String m, required String d}) {
    if (y.trim().isEmpty || m.trim().isEmpty || d.trim().isEmpty) {
      return 'Birth date is required';
    }

    final dt = parseYMD(y: y, m: m, d: d);
    if (dt == null) return 'Enter a valid birth date';

    final now = DateTime.now();
    if (dt.isAfter(now)) return 'Birth date cannot be in the future';

    return null;
  }
}
