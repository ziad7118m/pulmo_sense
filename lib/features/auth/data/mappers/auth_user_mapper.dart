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
    return AuthSession(
      user: toDomain(dto.user),
      tokens: SessionTokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      ),
    );
  }
}
