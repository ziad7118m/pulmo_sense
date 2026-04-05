import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/password_reset_challenge.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_service.dart';

class PasswordResetLocalDataSource {
  final LocalAuthService _service;

  const PasswordResetLocalDataSource(this._service);

  Future<Result<PasswordResetChallenge>> requestCode(String emailOrPhone) {
    return _service.requestPasswordReset(emailOrPhone);
  }

  Future<Result<Unit>> verifyCode({
    required String emailOrPhone,
    required String code,
  }) {
    return _service.verifyPasswordResetCode(
      emailOrPhone: emailOrPhone,
      code: code,
    );
  }

  Future<Result<Unit>> resetPassword({
    required String emailOrPhone,
    required String code,
    required String newPassword,
  }) {
    return _service.resetPassword(
      emailOrPhone: emailOrPhone,
      code: code,
      newPassword: newPassword,
    );
  }
}
