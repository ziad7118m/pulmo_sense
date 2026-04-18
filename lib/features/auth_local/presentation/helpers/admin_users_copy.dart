import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_users_kind.dart';

class AdminUsersCopy {
  const AdminUsersCopy._();

  static bool showRoleFilter(AdminUsersKind kind) {
    return kind != AdminUsersKind.doctors && kind != AdminUsersKind.patients && kind != AdminUsersKind.deleted;
  }

  static String heroTitle(AdminUsersKind kind) {
    switch (kind) {
      case AdminUsersKind.pending:
        return 'Review signup queue';
      case AdminUsersKind.active:
        return 'Monitor approved access';
      case AdminUsersKind.disabled:
        return 'Restore or keep accounts blocked';
      case AdminUsersKind.rejected:
        return 'Handle declined requests';
      case AdminUsersKind.deleted:
        return 'Restore deleted access';
      case AdminUsersKind.doctors:
        return 'Inspect doctor accounts';
      case AdminUsersKind.patients:
        return 'Inspect patient accounts';
    }
  }

  static String heroSubtitle(AdminUsersKind kind) {
    switch (kind) {
      case AdminUsersKind.pending:
        return 'Approve, reject, or disable new requests while keeping role intent clear.';
      case AdminUsersKind.active:
        return 'View everyone who can currently access the app.';
      case AdminUsersKind.disabled:
        return 'Re-enable users when access should be restored.';
      case AdminUsersKind.rejected:
        return 'Keep track of requests that were declined and reopen them if needed.';
      case AdminUsersKind.deleted:
        return 'Review soft-deleted accounts and restore them when needed.';
      case AdminUsersKind.doctors:
        return 'Focus on doctor profiles, moderation, and content readiness.';
      case AdminUsersKind.patients:
        return 'Focus on patient access and registration completeness.';
    }
  }
}
