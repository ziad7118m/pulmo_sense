import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/register_account_request.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/remembered_account_option.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_models.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/models/local_registration_profile_seed.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/models/remembered_account.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class LocalAuthBridge {
  const LocalAuthBridge._();

  static AuthUser authUserFromLocalUser(LocalUser user) {
    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: user.name,
      role: userRoleFromLocalRole(user.role),
      status: accountStatusFromLocalStatus(user.status),
      createdAt: user.createdAt,
    );
  }

  static UserRole userRoleFromLocalRole(LocalRole role) {
    switch (role) {
      case LocalRole.admin:
        return UserRole.admin;
      case LocalRole.doctor:
        return UserRole.doctor;
      case LocalRole.patient:
        return UserRole.patient;
    }
  }

  static LocalRole localRoleFromUserRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return LocalRole.admin;
      case UserRole.doctor:
        return LocalRole.doctor;
      case UserRole.patient:
        return LocalRole.patient;
    }
  }

  static UserAccountStatus accountStatusFromLocalStatus(AccountStatus status) {
    switch (status) {
      case AccountStatus.pending:
        return UserAccountStatus.pending;
      case AccountStatus.approved:
        return UserAccountStatus.approved;
      case AccountStatus.rejected:
        return UserAccountStatus.rejected;
      case AccountStatus.disabled:
        return UserAccountStatus.disabled;
    }
  }

  static LocalRegistrationProfileSeed registrationSeedFromRequest(
    RegisterAccountRequest request,
  ) {
    return LocalRegistrationProfileSeed(
      nationalId: request.nationalId,
      address: request.address,
      phone: request.phone,
      birthDate: request.birthDate,
      gender: request.gender,
      maritalStatus: request.maritalStatus,
      doctorLicense: request.doctorLicense,
    );
  }

  static RememberedAccountOption rememberedAccountOptionFromLocal(
    RememberedAccount account,
  ) {
    return RememberedAccountOption(
      email: account.email,
      password: account.password,
      displayName: account.displayName,
      avatarPath: account.avatarPath,
      roleLabel: account.roleLabel,
    );
  }
}
