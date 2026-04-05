import 'dart:io';

import 'package:dio/dio.dart';

class MultipartHelper {
  static Future<FormData> singleFile({
    required String fieldName,
    required String filePath,
    Map<String, dynamic>? fields,
  }) async {
    final file = File(filePath);

    // اسم الملف اللي هيتبعت
    final fileName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'upload.bin';

    final map = <String, dynamic>{};
    if (fields != null) map.addAll(fields);

    map[fieldName] = await MultipartFile.fromFile(
      filePath,
      filename: fileName,
    );

    return FormData.fromMap(map);
  }
}
