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

  static const Map<String, dynamic> _publicAuthExtra = {
    'skipAuthorization': true,
    'skipAuthRefresh': true,
  };

  Future<Result<LoginResponseDto>> login(LoginRequestDto request) {
    return _client.post<LoginResponseDto>(
      Endpoints.login,
      body: request.toJson(),
      extra: _publicAuthExtra,
      decode: (data) => LoginResponseDto.fromJson(Map<String, dynamic>.from((data ?? const <String, dynamic>{}) as Map)),
    );
  }

  Future<Result<String>> register(RegisterRequestDto request) {
    return _client.post<String>(
      request.endpoint,
      body: request.toJson(),
      extra: _publicAuthExtra,
      decode: (data) => (data ?? '').toString(),
    );
  }

  Future<Result<Unit>> sendOtp(String email) {
    return _client.post<Unit>(
      Endpoints.sendOtp,
      body: ForgotPasswordRequestDto(emailOrPhone: email).toJson(),
      extra: _publicAuthExtra,
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> verifyOtp({
    required String email,
    required String code,
  }) {
    return _client.post<Unit>(
      Endpoints.verifyOtp,
      body: VerifyResetCodeRequestDto(emailOrPhone: email, code: code).toJson(),
      extra: _publicAuthExtra,
      decode: (_) => Unit.value,
    );
  }

  Future<Result<LoginResponseDto>> refresh(RefreshRequestDto request) {
    return _client.post<LoginResponseDto>(
      Endpoints.refresh,
      body: request.toJson(),
      extra: _publicAuthExtra,
      decode: (data) => LoginResponseDto.fromJson(Map<String, dynamic>.from((data ?? const <String, dynamic>{}) as Map)),
    );
  }

  Future<Result<AuthUserDto>> me() {
    return _client.get<AuthUserDto>(
      Endpoints.me,
      decode: (data) {
        final map = Map<String, dynamic>.from(data as Map);
        return AuthUserDto(
          id: (map['id'] ?? map['userId'] ?? map['Id'] ?? map['UserId'] ?? '').toString(),
          email: (map['email'] ?? map['Email'] ?? '').toString(),
          displayName: (map['name'] ?? map['userName'] ?? map['displayName'] ?? map['UserName'] ?? '').toString(),
          role: (map['role'] ?? map['userType'] ?? 'Patient').toString(),
          status: (map['status'] ?? map['userStatus'] ?? 'Active').toString(),
        );
      },
    );
  }

  Future<Result<Unit>> logout(String refreshToken) {
    return _client.post<Unit>(
      Endpoints.logout,
      body: RefreshRequestDto(refreshToken: refreshToken).toJson(),
      extra: _publicAuthExtra,
      decode: (_) => Unit.value,
    );
  }

  Future<Result<List<AuthUserDto>>> fetchUsers({
    UserAccountStatus? status,
    UserRole? role,
  }) async {
    final allUsersResult = await _client.get<List<AuthUserDto>>(
      Endpoints.allUsers,
      decode: (data) => _decodeUsers(data, status: status, role: role),
    );

    if (allUsersResult is Success<List<AuthUserDto>>) {
      final items = allUsersResult.value;
      if (items.isNotEmpty || status != UserAccountStatus.pending) {
        return allUsersResult;
      }
    }

    if (status == UserAccountStatus.pending) {
      return _client.get<List<AuthUserDto>>(
        Endpoints.pendingUsers,
        decode: (data) => _decodeUsers(data, status: status, role: role),
      );
    }

    return allUsersResult;
  }

  Future<Result<AuthUserDto?>> findApprovedPatientById(String userId) {
    return Future.value(const Success<AuthUserDto?>(null));
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
    return _client.put<Unit>(
      Endpoints.approveUser(id),
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> rejectUser(String id) {
    return _client.put<Unit>(
      Endpoints.rejectUser(id),
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> disableUser(String id) {
    return _client.put<Unit>(
      Endpoints.disableUser(id),
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> enableUser(String id) {
    return _client.put<Unit>(
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

  Future<Result<Unit>> restoreUser(String id) {
    return _client.put<Unit>(
      Endpoints.restoreUser(id),
      decode: (_) => Unit.value,
    );
  }

  Future<Result<PasswordResetChallengeDto>> requestPasswordReset(
    ForgotPasswordRequestDto request,
  ) {
    return _client.post<PasswordResetChallengeDto>(
      Endpoints.forgotPassword,
      body: request.toJson(),
      extra: _publicAuthExtra,
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
      extra: _publicAuthExtra,
      decode: (_) => Unit.value,
    );
  }

  Future<Result<Unit>> resetPassword(ResetPasswordRequestDto request) {
    return _client.post<Unit>(
      Endpoints.resetPassword,
      body: request.toJson(),
      extra: _publicAuthExtra,
      decode: (_) => Unit.value,
    );
  }

  List<AuthUserDto> _decodeUsers(
    dynamic data, {
    UserAccountStatus? status,
    UserRole? role,
  }) {
    final list = _extractList(data);
    final users = list
        .map((item) => AuthUserDto.fromJson(Map<String, dynamic>.from(item as Map)))
        .where((user) => user.id.trim().isNotEmpty)
        .toList(growable: false);

    return users.where((user) {
      final parsedStatus = UserAccountStatusX.fromValue(user.status);
      final parsedRole = UserRoleX.fromValue(user.role);
      final matchesStatus = status == null || parsedStatus == status;
      final matchesRole = role == null || parsedRole == role;
      return matchesStatus && matchesRole;
    }).toList(growable: false);
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
