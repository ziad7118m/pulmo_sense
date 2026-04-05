enum StethoscopeTargetMode { patient, me }

extension StethoscopeTargetModeX on StethoscopeTargetMode {
  bool get isPatient => this == StethoscopeTargetMode.patient;
  bool get isDoctorSelf => this == StethoscopeTargetMode.me;
  String get storageValue => this == StethoscopeTargetMode.patient ? 'patient' : 'me';

  static StethoscopeTargetMode fromRaw(String? raw) {
    return raw == 'me' ? StethoscopeTargetMode.me : StethoscopeTargetMode.patient;
  }
}
