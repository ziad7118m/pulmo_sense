import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/password_reset_local_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/password_reset_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/password_reset_challenge.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/password_reset_repository.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final PasswordResetLocalDataSource _local;
  final PasswordResetRemoteDataSource? _remote;

  const PasswordResetRepositoryImpl({
    required PasswordResetLocalDataSource local,
    PasswordResetRemoteDataSource? remote,
  })  : _local = local,
        _remote = remote;

  @override
  Future<Result<PasswordResetChallenge>> requestCode(String emailOrPhone) {
    final remote = _remote;
    if (remote != null) {
      return remote.requestCode(emailOrPhone);
    }
    return _local.requestCode(emailOrPhone);
  }

  @override
  Future<Result<Unit>> verifyCode({
    required String emailOrPhone,
    required String code,
  }) {
    final remote = _remote;
    if (remote != null) {
      return remote.verifyCode(emailOrPhone: emailOrPhone, code: code);
    }
    return _local.verifyCode(emailOrPhone: emailOrPhone, code: code);
  }

  @override
  Future<Result<Unit>> resetPassword({
    required String emailOrPhone,
    required String code,
    required String newPassword,
  }) {
    final remote = _remote;
    if (remote != null) {
      return remote.resetPassword(
        emailOrPhone: emailOrPhone,
        code: code,
        newPassword: newPassword,
      );
    }
    return _local.resetPassword(
      emailOrPhone: emailOrPhone,
      code: code,
      newPassword: newPassword,
    );
  }
}
