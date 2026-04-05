import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class MedicalTargetAccountOption {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const MedicalTargetAccountOption({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}
