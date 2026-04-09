import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class RegisterAccountRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String nationalId;
  final String address;
  final String phone;
  final String birthDate;
  final String gender;
  final String maritalStatus;
  final String doctorLicense;

  const RegisterAccountRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.nationalId,
    required this.address,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.maritalStatus,
    required this.doctorLicense,
  });
}
