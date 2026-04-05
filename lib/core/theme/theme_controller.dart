import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/storage/app_storage.dart';
import 'package:lung_diagnosis_app/core/storage/keys.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> init() async {
    final isDark = await AppStorage.getBool(StorageKeys.themeIsDark, defaultValue: false);
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    await AppStorage.setBool(StorageKeys.themeIsDark, value);
    notifyListeners();
  }
}
