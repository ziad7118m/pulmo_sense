/// Central place for all named routes.
///
/// ✅ Keeps route strings out of UI.
/// ✅ Makes it easier to migrate to GoRouter later.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';

  // Auth
  static const login = '/login';
  static const start = '/start';
  static const roleSelection = '/role';
  static const authGate = '/auth-gate';

  // Shell
  static const shell = '/shell';

  // Diagnosis
  static const record = '/diagnosis/record';
  static const stethoscope = '/diagnosis/stethoscope';
  static const xray = '/diagnosis/xray';
}

/// Arguments for [AppRoutes.shell].
class ShellArgs {
  final bool isDoctor;

  const ShellArgs({required this.isDoctor});
}
