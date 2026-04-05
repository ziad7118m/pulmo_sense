import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';

List<AuthUser> filterAdminUsers(List<AuthUser> users, String query) {
  if (query.trim().isEmpty) return users;

  final normalizedQuery = query.trim().toLowerCase();
  return users.where((user) {
    final name = user.displayName.toLowerCase();
    final email = user.email.toLowerCase();
    return name.contains(normalizedQuery) || email.contains(normalizedQuery);
  }).toList();
}
