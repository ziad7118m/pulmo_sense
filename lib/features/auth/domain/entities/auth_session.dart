import 'package:lung_diagnosis_app/core/auth/session_tokens.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';

class AuthSession {
  final AuthUser user;
  final SessionTokens tokens;

  const AuthSession({
    required this.user,
    required this.tokens,
  });
}
