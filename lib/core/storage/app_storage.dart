import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage._();

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await _prefs;
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  static Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
