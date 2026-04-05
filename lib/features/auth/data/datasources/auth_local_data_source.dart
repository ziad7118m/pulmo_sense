import 'package:lung_diagnosis_app/core/auth/session_tokens.dart';
import 'package:lung_diagnosis_app/core/auth/token_store.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';

class AuthLocalDataSource {
  final TokenStore _tokenStore;
  AuthUser? _cachedUser;

  AuthLocalDataSource(this._tokenStore);

  Future<void> saveSession({
    required SessionTokens tokens,
    required AuthUser user,
  }) async {
    await _tokenStore.saveSession(tokens);
    _cachedUser = user;
  }

  Future<SessionTokens?> readTokens() => _tokenStore.readSession();

  Future<AuthUser?> readUser() async => _cachedUser;

  Future<void> saveUser(AuthUser user) async {
    _cachedUser = user;
  }

  Future<bool> hasSession() => _tokenStore.hasSession();

  Future<void> clear() async {
    _cachedUser = null;
    await _tokenStore.clear();
  }
}
