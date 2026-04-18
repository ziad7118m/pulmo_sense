import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_users_kind.dart';

class AdminDashboardSnapshot {
  final int pending;
  final int approved;
  final int disabled;
  final int rejected;
  final int deleted;
  final int doctors;
  final int patients;
  final int totalArticles;
  final int hiddenArticles;
  final int visibleArticles;

  const AdminDashboardSnapshot({
    this.pending = 0,
    this.approved = 0,
    this.disabled = 0,
    this.rejected = 0,
    this.deleted = 0,
    this.doctors = 0,
    this.patients = 0,
    this.totalArticles = 0,
    this.hiddenArticles = 0,
    this.visibleArticles = 0,
  });

  Map<AdminUsersKind, int> get userCounts => <AdminUsersKind, int>{
        AdminUsersKind.pending: pending,
        AdminUsersKind.active: approved,
        AdminUsersKind.disabled: disabled,
        AdminUsersKind.rejected: rejected,
        AdminUsersKind.deleted: deleted,
        AdminUsersKind.doctors: doctors,
        AdminUsersKind.patients: patients,
      };
}
