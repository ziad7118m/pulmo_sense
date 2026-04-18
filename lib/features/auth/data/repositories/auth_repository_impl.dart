import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/auth_user_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/login_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/login_response_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/refresh_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/register_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_session.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/login_credentials.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/register_account_request.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Result<AuthSession>> login(LoginCredentials credentials) async {
    final Result<LoginResponseDto> result = await _remote.login(
      LoginRequestDto(
        email: credentials.email.trim(),
        password: credentials.password,
      ),
    );
    if (result is FailureResult<LoginResponseDto>) {
      return FailureResult<AuthSession>(result.failure);
    }

    final dto = (result as Success<LoginResponseDto>).value;
    var session = AuthUserMapper.toSession(dto);
    await _local.saveSession(tokens: session.tokens, user: session.user);

    if (session.user.id.trim().isEmpty) {
      final currentUserResult = await fetchCurrentUser();
      if (currentUserResult is Success<AuthUser>) {
        session = AuthSession(user: currentUserResult.value, tokens: session.tokens);
        await _local.saveSession(tokens: session.tokens, user: session.user);
      }
    }

    return Success(session);
  }

  @override
  Future<Result<String>> register(RegisterAccountRequest request) async {
    final Result<String> result = await _remote.register(
      RegisterRequestDto(
        email: request.email.trim(),
        password: request.password,
        confirmPassword: request.confirmPassword,
        firstName: request.firstName,
        lastName: request.lastName,
        nationalId: request.nationalId,
        phoneNumber: request.phone,
        dateOfBirth: request.birthDate,
        gender: RegisterRequestDto.mapGender(request.gender),
        isMarried: RegisterRequestDto.mapMaritalStatus(request.maritalStatus),
        governorate: RegisterRequestDto.mapGovernorate(request.address),
        medicalLicense: request.role == UserRole.doctor ? request.doctorLicense.trim() : '',
        isDoctor: request.role == UserRole.doctor,
      ),
    );
    if (result is FailureResult<String>) {
      final failure = result.failure;
      final message = failure.message.toLowerCase();
      final shouldTryOtpRecovery =
          failure.statusCode == 500 ||
          message.contains('email already exists') ||
          message.contains('already exists') ||
          message.contains('verify your email');

      if (shouldTryOtpRecovery) {
        final otpResult = await _remote.sendOtp(request.email.trim());
        if (otpResult is Success<Unit>) {
          return const Success<String>('Account is ready for OTP verification.');
        }
      }

      return FailureResult<String>(failure);
    }
    return Success((result as Success<String>).value);
  }

  @override
  Future<Result<Unit>> sendEmailOtp(String email) {
    return _remote.sendOtp(email.trim());
  }

  @override
  Future<Result<Unit>> verifyEmailOtp({
    required String email,
    required String code,
  }) {
    return _remote.verifyOtp(email: email.trim(), code: code.trim());
  }

  @override
  Future<Result<AuthSession>> refreshSession() async {
    final tokens = await _local.readTokens();
    final refreshToken = tokens?.refreshToken ?? '';
    if (refreshToken.trim().isEmpty) {
      return const FailureResult<AuthSession>(
        AppFailure(
          type: FailureType.unauthorized,
          message: 'No refresh token available.',
        ),
      );
    }

    final Result<LoginResponseDto> result =
        await _remote.refresh(RefreshRequestDto(refreshToken: refreshToken));
    if (result is FailureResult<LoginResponseDto>) {
      return FailureResult<AuthSession>(result.failure);
    }

    final dto = (result as Success<LoginResponseDto>).value;
    var session = AuthUserMapper.toSession(dto);
    await _local.saveSession(tokens: session.tokens, user: session.user);

    if (session.user.id.trim().isEmpty) {
      final currentUserResult = await fetchCurrentUser();
      if (currentUserResult is Success<AuthUser>) {
        session = AuthSession(user: currentUserResult.value, tokens: session.tokens);
        await _local.saveSession(tokens: session.tokens, user: session.user);
      }
    }

    return Success(session);
  }

  @override
  Future<Result<AuthSession>> restoreSession() async {
    final tokens = await _local.readTokens();
    final hasSession = await _local.hasSession();
    if (!hasSession || tokens == null) {
      return const FailureResult<AuthSession>(
        AppFailure(
          type: FailureType.unauthorized,
          message: 'No stored session found.',
        ),
      );
    }

    final Result<AuthUser> currentUserResult = await fetchCurrentUser();
    if (currentUserResult is Success<AuthUser>) {
      return Success(
        AuthSession(
          user: currentUserResult.value,
          tokens: tokens,
        ),
      );
    }

    return refreshSession();
  }

  @override
  Future<Result<AuthUser>> fetchCurrentUser() async {
    final Result<AuthUserDto> result = await _remote.me();
    if (result is FailureResult<AuthUserDto>) {
      return FailureResult<AuthUser>(result.failure);
    }

    final user = AuthUserMapper.toDomain((result as Success<AuthUserDto>).value);
    await _local.saveUser(user);
    return Success(user);
  }

  @override
  Future<void> logout() async {
    final tokens = await _local.readTokens();
    final refreshToken = tokens?.refreshToken ?? '';
    if (refreshToken.trim().isNotEmpty) {
      await _remote.logout(refreshToken);
    }
    await _local.clear();
  }

  @override
  Future<AuthUser?> getCachedUser() => _local.readUser();

  @override
  Future<void> saveCachedUser(AuthUser user) => _local.saveUser(user);

  @override
  Future<Result<List<AuthUser>>> fetchUsers({
    UserAccountStatus? status,
    UserRole? role,
  }) async {
    final result = await _remote.fetchUsers(status: status, role: role);
    if (result is FailureResult<List<AuthUserDto>>) {
      return FailureResult<List<AuthUser>>(result.failure);
    }

    final items = (result as Success<List<AuthUserDto>>).value
        .map(AuthUserMapper.toDomain)
        .toList(growable: false);
    return Success(items);
  }

  @override
  Future<Result<AuthUser?>> findApprovedPatientById(String userId) async {
    final result = await _remote.findApprovedPatientById(userId);
    if (result is FailureResult<AuthUserDto?>) {
      return FailureResult<AuthUser?>(result.failure);
    }

    final dto = (result as Success<AuthUserDto?>).value;
    return Success(dto == null ? null : AuthUserMapper.toDomain(dto));
  }

  @override
  Future<Result<AuthUser?>> findApprovedPatientByNationalId(String nationalId) async {
    final result = await _remote.findApprovedPatientByNationalId(nationalId);
    if (result is FailureResult<AuthUserDto?>) {
      return FailureResult<AuthUser?>(result.failure);
    }

    final dto = (result as Success<AuthUserDto?>).value;
    return Success(dto == null ? null : AuthUserMapper.toDomain(dto));
  }

  @override
  Future<Result<Unit>> approveUser(String id, {UserRole? role}) {
    return _remote.approveUser(id, role: role);
  }

  @override
  Future<Result<Unit>> rejectUser(String id) {
    return _remote.rejectUser(id);
  }

  @override
  Future<Result<Unit>> disableUser(String id) {
    return _remote.disableUser(id);
  }

  @override
  Future<Result<Unit>> enableUser(String id) {
    return _remote.enableUser(id);
  }

  @override
  Future<Result<Unit>> deleteUser(String id) {
    return _remote.deleteUser(id);
  }

  @override
  Future<Result<Unit>> restoreUser(String id) {
    return _remote.restoreUser(id);
  }
}
