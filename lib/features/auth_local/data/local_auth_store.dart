import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_models.dart';

class LocalAuthStore {
  static const String usersBoxName = 'local_users';
  static const String sessionBoxName = 'local_session';

  final Map<String, LocalUser> _users = <String, LocalUser>{};
  LocalSession? _session;
  final List<Map<String, String>> _rememberedAccounts = <Map<String, String>>[];

  Future<void> upsertUser(LocalUser user) async {
    _users[user.id] = user;
  }

  Future<void> deleteUser(String userId) async {
    _users.remove(userId);
  }

  Future<List<LocalUser>> getAllUsers() async {
    return _users.values.toList(growable: false);
  }

  Future<LocalUser?> getUserById(String id) async {
    return _users[id];
  }

  Future<LocalUser?> findByEmail(String emailLower) async {
    final normalized = emailLower.trim().toLowerCase();
    for (final user in _users.values) {
      if (user.email.trim().toLowerCase() == normalized) {
        return user;
      }
    }
    return null;
  }

  Future<void> setSession(LocalSession? session) async {
    _session = session;
  }

  Future<LocalSession?> getSession() async {
    return _session;
  }

  Future<void> rememberAccount({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    _rememberedAccounts.removeWhere(
      (entry) => (entry['email'] ?? '').trim().toLowerCase() == normalized,
    );

    _rememberedAccounts.insert(0, <String, String>{
      'email': email,
      'password': password,
    });

    while (_rememberedAccounts.length > 5) {
      _rememberedAccounts.removeLast();
    }
  }

  Future<List<Map<String, String>>> getRememberedAccounts() async {
    return _rememberedAccounts
        .map((entry) => <String, String>{
              'email': entry['email'] ?? '',
              'password': entry['password'] ?? '',
            })
        .where((entry) => entry['email']!.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<void> forgetRememberedAccount(String email) async {
    final normalized = email.trim().toLowerCase();
    _rememberedAccounts.removeWhere(
      (entry) => (entry['email'] ?? '').trim().toLowerCase() == normalized,
    );
  }

  Future<void> clearAll() async {
    _users.clear();
    _session = null;
    _rememberedAccounts.clear();
  }
}
