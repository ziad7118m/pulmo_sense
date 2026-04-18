import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final UserAccountStatus status;
  final DateTime createdAt;
  final bool isDeleted;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    required this.createdAt,
    this.isDeleted = false,
  });

  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    UserAccountStatus? status,
    DateTime? createdAt,
    bool? isDeleted,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
