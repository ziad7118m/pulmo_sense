import 'package:lung_diagnosis_app/features/auth/domain/entities/register_account_request.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/signup_profile_seed.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class SignupRegisterRequestBuilder {
  const SignupRegisterRequestBuilder();

  RegisterAccountRequest build({
    required SignupProfileSeed seed,
    required UserRole role,
    required String email,
    required String password,
    required String confirmPassword,
    required String doctorLicense,
  }) {
    return RegisterAccountRequest(
      email: email.trim(),
      password: password,
      confirmPassword: confirmPassword,
      firstName: seed.firstName,
      lastName: seed.lastName,
      role: role,
      nationalId: seed.nationalId,
      address: seed.address,
      phone: seed.phone,
      birthDate: seed.birthDate,
      gender: seed.gender,
      maritalStatus: seed.maritalStatus,
      doctorLicense: role == UserRole.doctor ? doctorLicense.trim() : '',
    );
  }
}
