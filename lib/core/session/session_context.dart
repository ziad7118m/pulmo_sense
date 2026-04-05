import 'package:lung_diagnosis_app/core/di/app_di.dart';

class SessionContext {
  SessionContext._();

  static String? get userId => AppDI.session.userId;
  static String? get roleName => AppDI.session.roleName;

  static bool get hasUser => AppDI.session.hasUser;
  static bool get isAdmin => AppDI.session.isAdmin;
  static bool get isDoctor => AppDI.session.isDoctor;
  static bool get isPatient => AppDI.session.isPatient;

  static void setUser(String? id, {String? role}) {
    final normalizedId = (id ?? '').trim();
    if (normalizedId.isEmpty) {
      clear();
      return;
    }

    AppDI.session.setAuthenticatedUser(
      userId: normalizedId,
      roleName: (role ?? '').trim(),
    );
  }

  static void clear() {
    AppDI.session.clear();
  }
}
