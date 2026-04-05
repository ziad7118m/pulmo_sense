import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/helpers/admin_user_filter.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_user_list_view_data.dart';

class AdminUserListController {
  const AdminUserListController();

  Future<AdminUserListViewData> load({
    required Future<List<AuthUser>> Function(AuthController controller) loadUsers,
    required AuthController authController,
    required String query,
    bool Function(AuthUser user)? extraFilter,
  }) async {
    try {
      final users = await loadUsers(authController);
      final filteredUsers = filterAdminUsers(users, query).where((user) {
        if (extraFilter == null) return true;
        return extraFilter(user);
      }).toList(growable: false);

      return AdminUserListViewData(
        users: users,
        filteredUsers: filteredUsers,
      );
    } catch (_) {
      return AdminUserListViewData(
        users: const <AuthUser>[],
        filteredUsers: const <AuthUser>[],
        errorMessage: authController.error ?? 'Failed to load users. Please try again.',
      );
    }
  }

  Future<void> refresh() async {}
}
