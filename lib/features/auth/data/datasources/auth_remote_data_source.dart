import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/auth_user_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/forgot_password_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/login_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/login_response_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/password_reset_challenge_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/refresh_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/register_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/reset_password_request_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/verify_reset_code_request_dto.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class AuthRemoteDataSource {
  final ApiClient _client;

  const AuthRemoteDataSource(this._client);

  Future<Result<LoginResponseDto>> login(LoginRequestDto request) {
    return _client.post<LoginResponseDto>(
      Endpoints.login,
      body: request.toJson(),
      decode: (data) => LoginResponseDto.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Result<AuthUserDto>> register(RegisterRequestDto request) {
    return _client.post<AuthUserDto>(
      Endpoints.register,
      body: request.toJson(),
      decode: (data) => AuthUserDto.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Result<LoginResponseDto>> refresh(RefreshRequestDto request) {
    return _client.post<LoginResponseDto>(
      Endpoints.refresh,
      body: request.toJson(),
      decode: (data) => LoginResponseDto.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Result<AuthUserDto>> me() {
    return _client.get<AuthUserDto>(
      Endpoints.me,
      decode: (data) => AuthUserDto.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Result<Unit>> logout() {
    return _client.post<Unit>(
      Endpoints.logout,
      decode: (_) => Unit.value,
    );
  }

  Future<Result<List<AuthUserDto>>> fetchUsers({
    UserAccountStatus? status,
    UserRole? role,
  }) {
    return _client.get<List<AuthUserDto>>(
      Endpoints.adminUsers,
      query: {
        if (status != null) 'status': status.apiValue,
        if (role != null) 'role': role.apiValue,
      },
      decode: (data) {
        final list = _extractList(data);
        return list
            .map((item) => AuthUserDto.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(growable: false);
      },
    );
  }

  Future<Result<AuthUserDto?>> findApprovedPatientById(String userId) {
    final normalized = userId.trim();
    if (normalized.isEmpty) {
      return Future.value(const Success<AuthUserDto?>(null));
    }

    return _client.get<AuthUserDto?>(
      Endpoints.adminUsers,
      query: {
        'status': UserAccountStatus.approved.apiValue,
        'role': UserRole.patient.apiValue,
        'userId': normalized,
      },
      decode: (data) {
        final list = _extractList(data);
        if (list.isEmpty) return null;
        return AuthUserDto.fromJson(Map<String, dynamic>.from(list.first as Map));
      },
    );
  }

  Future<Result<AuthUserDto?>> findApprovedPatientByNationalId(String nationalId) {
    final normalized = nationalId.trim();
    if (normalized.isEmpty) {
      return Future.value(const Success<AuthUserDto?>(null));
    }

    return _client.get<AuthUserDto?>(
      Endpoints.doctorPatientResolve,
      query: {'nationalId': normalized},
      decode: (data) {
        if (data == null) return null;
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          final user = map['user'];
          if (user is Map) {
            return AuthUserDto.fromJson(Map<String, dynamic>.from(user));
          }
          if (map.containsKey('id') || map.containsKey('email')) {
            return AuthUserDto.fromJson(map);
          }
        }
        return null;
      },
    );
  }

  Future<Result<Unit>> approveUser(String id, {UserRole? role}) {
    return _client.post<Unit>(
      Endpoints.approveUser(id),
      body: role == null ? null : {'role': role.apiValue},
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> rejectUser(String id) {
    return _client.post<Unit>(
      Endpoints.rejectUser(id),
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> disableUser(String id) {
    return _client.post<Unit>(
      Endpoints.disableUser(id),
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> enableUser(String id) {
    return _client.post<Unit>(
      Endpoints.enableUser(id),
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> deleteUser(String id) {
    return _client.delete<Unit>(
      Endpoints.deleteUser(id),
      decode: (_) => Unit.value,
    );
  }

  Future<Result<PasswordResetChallengeDto>> requestPasswordReset(
    ForgotPasswordRequestDto request,
  ) {
    return _client.post<PasswordResetChallengeDto>(
      Endpoints.forgotPassword,
      body: request.toJson(),
      decode: (data) {
        if (data is Map) {
          return PasswordResetChallengeDto.fromJson(Map<String, dynamic>.from(data));
        }
        return const PasswordResetChallengeDto(deliveryHint: '');
      },
    );
  }

  Future<Result<Unit>> verifyResetCode(VerifyResetCodeRequestDto request) {
    return _client.post<Unit>(
      Endpoints.verifyResetCode,
      body: request.toJson(),
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> resetPassword(ResetPasswordRequestDto request) {
    return _client.post<Unit>(
      Endpoints.resetPassword,
      body: request.toJson(),
      decode: (_) => Unit.value,
    );
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final candidates = [map['items'], map['users'], map['data'], map['results']];
      for (final candidate in candidates) {
        if (candidate is List) return candidate;
      }
    }
    return const <dynamic>[];
  }
}
