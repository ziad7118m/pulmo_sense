import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImagePaths {
  static Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  static Future<String> newXrayPath({String ext = 'jpg'}) async {
    final dir = await _baseDir();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/xray_$ts.$ext';
  }

  static String _guessExt(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.jpeg')) return 'jpeg';
    if (lower.endsWith('.jpg')) return 'jpg';
    return 'jpg';
  }

  static Future<File> persistPickedImage(String pickedPath) async {
    final ext = _guessExt(pickedPath);
    final newPath = await newXrayPath(ext: ext);
    final src = File(pickedPath);
    return src.copy(newPath);
  }
}
