enum DiagnosisKind { record, stethoscope, xray }

extension DiagnosisKindX on DiagnosisKind {
  String get storageKey => name;
  String get apiSegment => name;
  bool get isAudio => this == DiagnosisKind.record || this == DiagnosisKind.stethoscope;
  bool get isImaging => this == DiagnosisKind.xray;

  static DiagnosisKind fromValue(String raw) {
    return DiagnosisKind.values.firstWhere(
      (value) => value.name == raw.trim().toLowerCase(),
      orElse: () => DiagnosisKind.record,
    );
  }
}
