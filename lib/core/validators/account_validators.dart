class AccountValidators {
  static final RegExp _emailRx = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Egypt mobile numbers (common): 11 digits, starts with 01.
  static final RegExp _egPhoneRx = RegExp(r'^01[0-2,5]\d{8}$');

  static String? requiredText(String? v, {String message = 'Required'}) {
    if (v == null || v.trim().isEmpty) return message;
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    final s = v.trim();
    if (s.length < 2) return 'Name is too short';
    return null;
  }

  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required';
    if (!_emailRx.hasMatch(s)) return 'Invalid email format';
    return null;
  }

  static String? egyptPhone(String? v) {
    final s = (v ?? '').trim().replaceAll(' ', '');
    if (s.isEmpty) return 'Phone number is required';
    if (!_egPhoneRx.hasMatch(s)) return 'Invalid Egyptian phone (e.g. 01xxxxxxxxx)';
    return null;
  }

  /// Egypt National ID: 14 digits.
  static String? nationalId(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'National ID is required';
    if (s.length != 14) return 'National ID must be 14 digits';
    if (int.tryParse(s) == null) return 'National ID must be numeric';
    return null;
  }

  static String? password(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Password is required';
    if (s.length < 8) return 'Password must be at least 8 characters';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(s);
    final hasNumber = RegExp(r'\d').hasMatch(s);
    if (!hasLetter || !hasNumber) return 'Password must include letters and numbers';
    return null;
  }

  static String? license(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'License number is required';
    if (s.length < 4) return 'License number is too short';
    return null;
  }

  static DateTime? parseYMD({required String y, required String m, required String d}) {
    final yy = int.tryParse(y.trim());
    final mm = int.tryParse(m.trim());
    final dd = int.tryParse(d.trim());
    if (yy == null || mm == null || dd == null) return null;
    try {
      final dt = DateTime(yy, mm, dd);
      // DateTime normalizes invalid dates; verify exact match.
      if (dt.year != yy || dt.month != mm || dt.day != dd) return null;
      return dt;
    } catch (_) {
      return null;
    }
  }

  static String? birthDateYMD({required String y, required String m, required String d}) {
    final dt = parseYMD(y: y, m: m, d: d);
    if (dt == null) return 'Invalid birth date';
    final now = DateTime.now();
    if (dt.isAfter(now)) return 'Birth date cannot be in the future';
    final age = now.year - dt.year - ((now.month < dt.month || (now.month == dt.month && now.day < dt.day)) ? 1 : 0);
    if (age < 0 || age > 120) return 'Birth date is not realistic';
    return null;
  }
}
