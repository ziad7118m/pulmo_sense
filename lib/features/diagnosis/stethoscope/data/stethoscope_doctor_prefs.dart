import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-only preferences for doctor stethoscope flow.
/// Stores last selected patient input & resolved patient id.
class StethoscopeDoctorPrefs {
  static String _key(String doctorId) => 'stetho_last_patient_$doctorId';

  static Future<void> save({
    required String doctorId,
    required String mode, // 'account' | 'national'
    required String rawValue,
    required String resolvedPatientId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'mode': mode,
      'rawValue': rawValue,
      'resolvedPatientId': resolvedPatientId,
      'ts': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_key(doctorId), payload);
  }

  static Future<StethoscopeDoctorPrefsData?> load(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(doctorId));
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final m = jsonDecode(raw);
      if (m is! Map) return null;
      return StethoscopeDoctorPrefsData(
        mode: (m['mode'] ?? 'account').toString(),
        rawValue: (m['rawValue'] ?? '').toString(),
        resolvedPatientId: (m['resolvedPatientId'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(doctorId));
  }
}

class StethoscopeDoctorPrefsData {
  final String mode;
  final String rawValue;
  final String resolvedPatientId;

  const StethoscopeDoctorPrefsData({
    required this.mode,
    required this.rawValue,
    required this.resolvedPatientId,
  });
}
