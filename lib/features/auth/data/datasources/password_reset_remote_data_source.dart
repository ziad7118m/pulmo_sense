import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/forgot_password_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/password_reset_challenge_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/reset_password_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/password_reset_challenge.dart';

class PasswordResetRemoteDataSource {
  final AuthRemoteDataSource _authRemoteDataSource;

  const PasswordResetRemoteDataSource(this._authRemoteDataSource);

  Future<Result<PasswordResetChallenge>> requestCode(String emailOrPhone) async {
    final Result<PasswordResetChallengeDto> result =
        await _authRemoteDataSource.requestPasswordReset(
      ForgotPasswordRequestDto(emailOrPhone: emailOrPhone),
    );

    if (result is FailureResult<PasswordResetChallengeDto>) {
      return FailureResult<PasswordResetChallenge>(result.failure);
    }

    final dto = (result as Success<PasswordResetChallengeDto>).value;
    return Success(dto.toDomain());
  }

  Future<Result<Unit>> verifyCode({
    required String emailOrPhone,
    required String code,
  }) {
    // Backend validates the OTP again inside ResetPassword and marks it used there.
    // Returning success here keeps the Flutter flow compatible until the backend exposes
    // a dedicated non-consuming reset verification endpoint.
    return Future.value(const Success<Unit>(Unit.value));
  }

  Future<Result<Unit>> resetPassword({
    required String emailOrPhone,
    required String code,
    required String newPassword,
  }) {
    return _authRemoteDataSource.resetPassword(
      ResetPasswordRequestDto(
        emailOrPhone: emailOrPhone,
        code: code,
        newPassword: newPassword,
      ),
    );
  }
}
