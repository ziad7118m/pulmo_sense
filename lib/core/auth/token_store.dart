import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lung_diagnosis_app/core/auth/session_tokens.dart';

class TokenStore {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  TokenStore(this._storage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return saveSession(
      SessionTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
  }

  Future<void> saveSession(SessionTokens tokens) async {
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  Future<SessionTokens?> readSession() async {
    final accessToken = await _storage.read(key: _accessKey);
    final refreshToken = await _storage.read(key: _refreshKey);

    final access = accessToken?.trim() ?? '';
    final refresh = refreshToken?.trim() ?? '';
    if (access.isEmpty && refresh.isEmpty) return null;

    return SessionTokens(
      accessToken: access,
      refreshToken: refresh,
    );
  }

  Future<void> saveAccessToken(String accessToken) {
    return _storage.write(key: _accessKey, value: accessToken);
  }

  Future<void> saveRefreshToken(String refreshToken) {
    return _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    final session = await readSession();
    final token = session?.accessToken ?? '';
    return token.isEmpty ? null : token;
  }

  Future<String?> getRefreshToken() async {
    final session = await readSession();
    final token = session?.refreshToken ?? '';
    return token.isEmpty ? null : token;
  }

  Future<bool> hasSession() async {
    final session = await readSession();
    return session?.isComplete ?? false;
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
