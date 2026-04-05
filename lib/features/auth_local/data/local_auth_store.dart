import 'package:hive/hive.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_models.dart';

class LocalAuthStore {
  static const String usersBoxName = 'local_users';
  static const String sessionBoxName = 'local_session';
  static const String _kSession = 'session';
  static const String _kRememberedAccounts = 'remembered_accounts';

  Future<Box> _usersBox() => Hive.openBox(usersBoxName);
  Future<Box> _sessionBox() => Hive.openBox(sessionBoxName);

  Future<void> upsertUser(LocalUser user) async {
    final box = await _usersBox();
    await box.put(user.id, user.toMap());
  }

  Future<void> deleteUser(String userId) async {
    final box = await _usersBox();
    await box.delete(userId);
  }

  Future<List<LocalUser>> getAllUsers() async {
    final box = await _usersBox();
    return box.values
        .whereType<Map>()
        .map((m) => LocalUser.fromMap(m))
        .toList();
  }

  Future<LocalUser?> getUserById(String id) async {
    final box = await _usersBox();
    final v = box.get(id);
    if (v is Map) return LocalUser.fromMap(v);
    return null;
  }

  Future<LocalUser?> findByEmail(String emailLower) async {
    final all = await getAllUsers();
    for (final u in all) {
      if (u.email.toLowerCase() == emailLower) return u;
    }
    return null;
  }

  Future<void> setSession(LocalSession? session) async {
    final box = await _sessionBox();
    if (session == null) {
      await box.delete(_kSession);
    } else {
      await box.put(_kSession, session.toMap());
    }
  }

  Future<LocalSession?> getSession() async {
    final box = await _sessionBox();
    return LocalSession.fromMap(box.get(_kSession));
  }

  /// Stores only accounts that succeeded to login.
  ///
  /// We keep a small list to power the email dropdown on the login page.
  Future<void> rememberAccount({required String email, required String password}) async {
    final box = await _sessionBox();
    final current = (box.get(_kRememberedAccounts) as List?)?.whereType<Map>().toList() ?? <Map>[];

    // Remove any existing record for the same email (case-insensitive)
    current.removeWhere((m) => (m['email'] ?? '').toString().toLowerCase() == email.toLowerCase());

    current.insert(0, {
      'email': email,
      'password': password,
      'lastUsedAt': DateTime.now().toIso8601String(),
    });

    // Keep the latest 5.
    while (current.length > 5) {
      current.removeLast();
    }

    await box.put(_kRememberedAccounts, current);
  }

  Future<List<Map<String, String>>> getRememberedAccounts() async {
    final box = await _sessionBox();
    final raw = (box.get(_kRememberedAccounts) as List?)?.whereType<Map>().toList() ?? <Map>[];
    return raw
        .map((m) => {
      'email': (m['email'] ?? '').toString(),
      'password': (m['password'] ?? '').toString(),
    })
        .where((m) => m['email']!.trim().isNotEmpty)
        .toList();
  }

  Future<void> forgetRememberedAccount(String email) async {
    final box = await _sessionBox();
    final current = (box.get(_kRememberedAccounts) as List?)?.whereType<Map>().toList() ?? <Map>[];
    current.removeWhere((m) => (m['email'] ?? '').toString().toLowerCase() == email.toLowerCase());
    await box.put(_kRememberedAccounts, current);
  }

  Future<void> clearAll() async {
    final u = await _usersBox();
    final s = await _sessionBox();
    await u.clear();
    await s.clear();
  }
}
