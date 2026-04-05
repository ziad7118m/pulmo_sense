import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';

class AdminUserListViewData {
  final List<AuthUser> users;
  final List<AuthUser> filteredUsers;
  final String? errorMessage;

  const AdminUserListViewData({
    required this.users,
    required this.filteredUsers,
    this.errorMessage,
  });

  bool get isEmpty => filteredUsers.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
}
