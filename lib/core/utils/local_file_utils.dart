import 'dart:io';

class LocalFileUtils {
  const LocalFileUtils._();

  static bool isManagedLocalPath(String? path) {
    final normalized = (path ?? '').trim();
    if (normalized.isEmpty) return false;
    if (normalized.startsWith('assets/')) return false;

    final uri = Uri.tryParse(normalized);
    final scheme = (uri?.scheme ?? '').toLowerCase();
    if (scheme == 'http' || scheme == 'https' || scheme == 'data') {
      return false;
    }

    return true;
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
