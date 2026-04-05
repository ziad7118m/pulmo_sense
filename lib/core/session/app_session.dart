import 'package:flutter/foundation.dart';

class SessionSnapshot {
  final String? userId;
  final String? roleName;

  const SessionSnapshot({
    this.userId,
    this.roleName,
  });

  bool get hasUser => (userId ?? '').trim().isNotEmpty;
  bool get isAdmin => roleName == 'admin';
  bool get isDoctor => roleName == 'doctor';
  bool get isPatient => roleName == 'patient';

  SessionSnapshot copyWith({
    String? userId,
    String? roleName,
  }) {
    return SessionSnapshot(
      userId: userId ?? this.userId,
      roleName: roleName ?? this.roleName,
    );
  }
}

class AppSession extends ChangeNotifier {
  SessionSnapshot _snapshot = const SessionSnapshot();

  SessionSnapshot get snapshot => _snapshot;

  String? get userId => _snapshot.userId;
  String? get roleName => _snapshot.roleName;

  bool get hasUser => _snapshot.hasUser;
  bool get isAdmin => _snapshot.isAdmin;
  bool get isDoctor => _snapshot.isDoctor;
  bool get isPatient => _snapshot.isPatient;

  void setAuthenticatedUser({
    required String userId,
    required String roleName,
  }) {
    final normalizedUserId = userId.trim();
    final normalizedRole = roleName.trim();

    if (normalizedUserId.isEmpty) {
      clear();
      return;
    }

    final next = SessionSnapshot(
      userId: normalizedUserId,
      roleName: normalizedRole.isEmpty ? null : normalizedRole,
    );

    if (_snapshot.userId == next.userId && _snapshot.roleName == next.roleName) {
      return;
    }

    _snapshot = next;
    notifyListeners();
  }

  void clear() {
    if (!_snapshot.hasUser && (_snapshot.roleName ?? '').isEmpty) {
      return;
    }
    _snapshot = const SessionSnapshot();
    notifyListeners();
  }
}
