import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_session.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/login_credentials.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/register_account_request.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> login(LoginCredentials credentials);
  Future<Result<AuthUser>> register(RegisterAccountRequest request);
  Future<Result<AuthSession>> refreshSession();
  Future<Result<AuthSession>> restoreSession();
  Future<Result<AuthUser>> fetchCurrentUser();
  Future<void> logout();
  Future<AuthUser?> getCachedUser();
  Future<void> saveCachedUser(AuthUser user);

  Future<Result<List<AuthUser>>> fetchUsers({
    UserAccountStatus? status,
    UserRole? role,
  });

  Future<Result<AuthUser?>> findApprovedPatientById(String userId);
  Future<Result<AuthUser?>> findApprovedPatientByNationalId(String nationalId);
  Future<Result<Unit>> approveUser(String id, {UserRole? role});
  Future<Result<Unit>> rejectUser(String id);
  Future<Result<Unit>> disableUser(String id);
  Future<Result<Unit>> enableUser(String id);
  Future<Result<Unit>> deleteUser(String id);
}
