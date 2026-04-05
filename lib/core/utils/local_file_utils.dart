import 'dart:io';

class LocalFileUtils {
  const LocalFileUtils._();

  static bool isManagedLocalPath(String? path) {
    return path != null && path.isNotEmpty && !path.startsWith('assets/');
  }

  static Future<void> deleteIfExists(String? path) async {
    if (!isManagedLocalPath(path)) return;

    try {
      final file = File(path!);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static void deleteIfExistsSync(String? path) {
    if (!isManagedLocalPath(path)) return;

    try {
      final file = File(path!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }
}
