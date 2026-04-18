import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_dashboard_snapshot.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

Future<AdminDashboardSnapshot> loadAdminDashboardSnapshot({
  required AuthController authController,
}) async {
  try {
    final users = await authController.fetchAllUsersForAdminDashboard();

    final pending = _countByStatus(users, UserAccountStatus.pending, includeDeleted: false);
    final approved = _countByStatus(users, UserAccountStatus.approved, includeDeleted: false, excludeAdmins: true);
    final disabled = _countByStatus(users, UserAccountStatus.disabled, includeDeleted: false);
    final rejected = _countByStatus(users, UserAccountStatus.rejected, includeDeleted: false);
    final deleted = users.where((user) => user.isDeleted).length;
    final doctors = _countByRole(users, UserRole.doctor);
    final patients = _countByRole(users, UserRole.patient);

    return AdminDashboardSnapshot(
      pending: pending,
      approved: approved,
      disabled: disabled,
      rejected: rejected,
      deleted: deleted,
      doctors: doctors,
      patients: patients,
    );
  } catch (_) {
    return const AdminDashboardSnapshot();
  }
}

int _countByStatus(
  List<AuthUser> users,
  UserAccountStatus status, {
  required bool includeDeleted,
  bool excludeAdmins = false,
}) {
  return users.where((user) {
    if (!includeDeleted && user.isDeleted) return false;
    if (excludeAdmins && user.role.isAdmin) return false;
    return user.status == status;
  }).length;
}

int _countByRole(List<AuthUser> users, UserRole role) {
  return users.where((user) {
    if (user.isDeleted) return false;
    if (user.status != UserAccountStatus.approved) return false;
    return user.role == role;
  }).length;
}
