import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_models.dart';

extension LocalRoleX on LocalRole {
  bool get isAdmin => this == LocalRole.admin;
  bool get isDoctor => this == LocalRole.doctor;
  bool get isPatient => this == LocalRole.patient;

  String get displayName {
    switch (this) {
      case LocalRole.admin:
        return 'Admin';
      case LocalRole.doctor:
        return 'Doctor';
      case LocalRole.patient:
        return 'Patient';
    }
  }
}

extension AccountStatusX on AccountStatus {
  String get displayName {
    switch (this) {
      case AccountStatus.pending:
        return 'Pending';
      case AccountStatus.approved:
        return 'Approved';
      case AccountStatus.rejected:
        return 'Rejected';
      case AccountStatus.disabled:
        return 'Disabled';
    }
  }
}
