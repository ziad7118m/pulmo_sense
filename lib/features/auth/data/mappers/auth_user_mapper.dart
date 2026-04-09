import 'dart:convert';

import 'package:lung_diagnosis_app/core/auth/session_tokens.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/auth_user_dto.dart';
import 'package:lung_diagnosis_app/features/auth/data/dtos/login_response_dto.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_session.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class AuthUserMapper {
  static AuthUser toDomain(AuthUserDto dto) {
    return AuthUser(
      id: dto.id,
      email: dto.email,
      displayName: dto.displayName,
      role: UserRoleX.fromValue(dto.role),
      status: UserAccountStatusX.fromValue(dto.status),
      createdAt: dto.createdAt ?? DateTime.now(),
    );
  }

  static AuthSession toSession(LoginResponseDto dto) {
    final claims = _JwtClaims.tryParse(dto.accessToken);
    final resolvedUser = AuthUserDto(
      id: dto.user.id.trim().isNotEmpty ? dto.user.id.trim() : claims.userId,
      email: dto.user.email.trim().isNotEmpty ? dto.user.email.trim() : claims.email,
      displayName: dto.user.displayName.trim().isNotEmpty
          ? dto.user.displayName.trim()
          : claims.displayName,
      role: dto.user.role.trim().isNotEmpty ? dto.user.role.trim() : claims.role,
      status: dto.user.status,
      createdAt: dto.user.createdAt,
    );

    return AuthSession(
      user: toDomain(resolvedUser),
      tokens: SessionTokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      ),
    );
  }
}

class _JwtClaims {
  final String userId;
  final String email;
  final String displayName;
  final String role;

  const _JwtClaims({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
  });

  static const _empty = _JwtClaims(
    userId: '',
    email: '',
    displayName: '',
    role: 'Patient',
  );

  static _JwtClaims tryParse(String token) {
    final normalized = token.trim();
    if (normalized.isEmpty) return _empty;

    try {
      final parts = normalized.split('.');
      if (parts.length < 2) return _empty;
      final payload = _decodeBase64Url(parts[1]);
      final map = jsonDecode(payload);
      if (map is! Map) return _empty;
      final claims = Map<String, dynamic>.from(map);

      String readClaim(List<String> keys) {
        for (final key in keys) {
          final value = claims[key];
          final text = value?.toString().trim() ?? '';
          if (text.isNotEmpty) return text;
        }
        return '';
      }

      return _JwtClaims(
        userId: readClaim(const [
          'nameid',
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
          'sub',
        ]),
        email: readClaim(const [
          'email',
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
        ]),
        displayName: readClaim(const [
          'unique_name',
          'name',
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
        ]),
        role: readClaim(const [
          'UserType',
          'role',
          'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
        ]),
      );
    } catch (_) {
      return _empty;
    }
  }

  static String _decodeBase64Url(String input) {
    var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    final remainder = normalized.length % 4;
    if (remainder != 0) {
      normalized = normalized.padRight(normalized.length + (4 - remainder), '=');
    }
    return utf8.decode(base64.decode(normalized));
  }
}
