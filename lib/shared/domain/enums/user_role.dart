enum UserRole { admin, doctor, patient }

extension UserRoleX on UserRole {
  bool get isAdmin => this == UserRole.admin;
  bool get isDoctor => this == UserRole.doctor;
  bool get isPatient => this == UserRole.patient;

  String get apiValue => name;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.patient:
        return 'Patient';
    }
  }

  static UserRole fromValue(String raw) {
    return UserRole.values.firstWhere(
      (value) => value.name == raw.trim().toLowerCase(),
      orElse: () => UserRole.patient,
    );
  }
}
