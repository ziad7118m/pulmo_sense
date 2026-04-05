import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_models.dart';

class RememberedAccount {
  final String email;
  final String password;
  final LocalRole? role;
  final String avatarPath;
  final String name;

  const RememberedAccount({
    required this.email,
    required this.password,
    required this.role,
    required this.avatarPath,
    required this.name,
  });

  String get displayName => name.trim().isNotEmpty ? name : email;

  String get roleLabel {
    switch (role) {
      case LocalRole.doctor:
        return 'Doctor';
      case LocalRole.patient:
        return 'Patient';
      case LocalRole.admin:
        return 'Admin';
      case null:
        return '';
    }
  }
}
