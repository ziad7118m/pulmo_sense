import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/password_reset_challenge.dart';

abstract class PasswordResetRepository {
  Future<Result<PasswordResetChallenge>> requestCode(String emailOrPhone);
  Future<Result<Unit>> verifyCode({
    required String emailOrPhone,
    required String code,
  });
  Future<Result<Unit>> resetPassword({
    required String emailOrPhone,
    required String code,
    required String newPassword,
  });
}
