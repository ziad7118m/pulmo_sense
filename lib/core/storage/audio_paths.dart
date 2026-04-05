import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioPaths {
  static Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  static Future<String> newRecordingPath({required String prefix}) async {
    final dir = await _baseDir();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/${prefix}_$ts.m4a';
  }
}
