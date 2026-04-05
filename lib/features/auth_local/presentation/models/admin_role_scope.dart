import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

/// UI-only filter scope used inside Admin Users page.
enum AdminRoleScope { all, doctors, patients }

extension AdminRoleScopeX on AdminRoleScope {
  String get label {
    switch (this) {
      case AdminRoleScope.all:
        return 'All roles';
      case AdminRoleScope.doctors:
        return 'Doctors';
      case AdminRoleScope.patients:
        return 'Patients';
    }
  }

  bool matches(AuthUser user) {
    switch (this) {
      case AdminRoleScope.all:
        return true;
      case AdminRoleScope.doctors:
        return user.role.isDoctor;
      case AdminRoleScope.patients:
        return user.role.isPatient;
    }
  }
}
