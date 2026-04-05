import 'dart:io';

import 'package:lung_diagnosis_app/core/failures/failure.dart';

class FileValidators {
  // عدّل الأرقام دي براحتك لاحقاً حسب backend limits
  static const int maxAudioBytes = 12 * 1024 * 1024; // 12 MB
  static const int maxImageBytes = 10 * 1024 * 1024; // 10 MB

  static const Set<String> allowedAudioExt = {
    'wav',
    'm4a',
    'aac',
    'mp3',
    'ogg',
  };

  static const Set<String> allowedImageExt = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  static String _ext(String path) {
    final i = path.lastIndexOf('.');
    if (i == -1) return '';
    return path.substring(i + 1).toLowerCase();
  }

  static AppFailure? validateExistingFile({
    required String path,
    required int maxBytes,
    required Set<String> allowedExt,
    required String kindLabel, // "audio" / "image"
  }) {
    if (path.trim().isEmpty) {
      return const AppFailure(
        type: FailureType.validation,
        message: 'Empty file path',
      );
    }

    // Assets paths we don't validate as real files
    if (path.startsWith('assets/')) return null;

    final file = File(path);
    if (!file.existsSync()) {
      return AppFailure(
        type: FailureType.validation,
        message: 'File not found ($kindLabel)',
        details: path,
      );
    }

    final ext = _ext(path);
    if (ext.isEmpty || !allowedExt.contains(ext)) {
      return AppFailure(
        type: FailureType.validation,
        message: 'Unsupported $kindLabel format: .$ext',
        details: path,
      );
    }

    final bytes = file.lengthSync();
    if (bytes <= 0) {
      return AppFailure(
        type: FailureType.validation,
        message: 'Empty $kindLabel file',
        details: path,
      );
    }

    if (bytes > maxBytes) {
      return AppFailure(
        type: FailureType.validation,
        message: '$kindLabel file is too large (${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB)',
        details: {'maxBytes': maxBytes, 'actualBytes': bytes},
      );
    }

    return null;
  }

  static AppFailure? validateAudio(String path) {
    return validateExistingFile(
      path: path,
      maxBytes: maxAudioBytes,
      allowedExt: allowedAudioExt,
      kindLabel: 'audio',
    );
  }

  static AppFailure? validateImage(String path) {
    return validateExistingFile(
      path: path,
      maxBytes: maxImageBytes,
      allowedExt: allowedImageExt,
      kindLabel: 'image',
    );
  }
}
