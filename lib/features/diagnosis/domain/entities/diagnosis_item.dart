enum AudioSourceType {
  recorded,
  uploaded,
}

extension AudioSourceTypeX on AudioSourceType {
  int toInt() {
    switch (this) {
      case AudioSourceType.recorded:
        return 0;
      case AudioSourceType.uploaded:
        return 1;
    }
  }

  static AudioSourceType? fromInt(int value) {
    switch (value) {
      case 0:
        return AudioSourceType.recorded;
      case 1:
        return AudioSourceType.uploaded;
      default:
        return null;
    }
  }
}

class DiagnosisItem {
  final String id;
  final String dateTime;
  final String diagnosis;
  final double percentage;
  final String? imagePath;
  final String? audioPath;
  final List<double>? waveSamples;
  final AudioSourceType? audioSourceType;
  final String? createdByDoctorId;
  final String? createdByDoctorName;
  final String? targetPatientId;
  final String? targetPatientName;

  const DiagnosisItem({
    required this.id,
    required this.dateTime,
    required this.diagnosis,
    required this.percentage,
    this.imagePath,
    this.audioPath,
    this.waveSamples,
    this.audioSourceType,
    this.createdByDoctorId,
    this.createdByDoctorName,
    this.targetPatientId,
    this.targetPatientName,
  });

  static String nextId() => 'diag_${DateTime.now().microsecondsSinceEpoch}';
}

String legacyDiagnosisItemId({
  required String dateTime,
  required String diagnosis,
  required double percentage,
  String? imagePath,
  String? audioPath,
  List<double>? waveSamples,
}) {
  final raw = [
    dateTime.trim(),
    diagnosis.trim(),
    percentage.toStringAsFixed(4),
    (imagePath ?? '').trim(),
    (audioPath ?? '').trim(),
    if (waveSamples != null && waveSamples.isNotEmpty)
      waveSamples.map((sample) => sample.toStringAsFixed(4)).join(','),
  ].join('|');

  return 'legacy_${_stableHexHash(raw)}';
}

String _stableHexHash(String input) {
  var hash = 0x811c9dc5;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
