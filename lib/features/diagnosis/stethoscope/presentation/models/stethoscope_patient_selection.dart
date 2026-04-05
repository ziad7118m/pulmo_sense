class StethoscopePatientSelection {
  final String queryValue;
  final String? patientId;
  final String? patientName;
  final String? avatarPath;
  final String? errorMessage;

  const StethoscopePatientSelection._({
    required this.queryValue,
    required this.patientId,
    required this.patientName,
    required this.avatarPath,
    required this.errorMessage,
  });

  const StethoscopePatientSelection.success({
    required String queryValue,
    required String patientId,
    required String patientName,
    String? avatarPath,
  }) : this._(
          queryValue: queryValue,
          patientId: patientId,
          patientName: patientName,
          avatarPath: avatarPath,
          errorMessage: null,
        );

  const StethoscopePatientSelection.failure({
    required String queryValue,
    required String errorMessage,
  }) : this._(
          queryValue: queryValue,
          patientId: null,
          patientName: null,
          avatarPath: null,
          errorMessage: errorMessage,
        );

  bool get hasPatient =>
      patientId != null && patientId!.trim().isNotEmpty &&
      patientName != null && patientName!.trim().isNotEmpty;
}
