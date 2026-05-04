import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/auth_gate_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/login_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/role_selection_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/start_screen.dart';
import 'package:lung_diagnosis_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/pages/main_layout_doctor.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/pages/main_layout_patient.dart';
import 'package:lung_diagnosis_app/features/splash/presentation/pages/splash_screen.dart';

import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _material(const SplashScreen());

      case AppRoutes.onboarding:
        return _material(const OnboardingScreen());

      case AppRoutes.login:
        return _material(const LoginScreen());

      case AppRoutes.start:
        return _material(const StartScreen());

      case AppRoutes.roleSelection:
        return _material(const RoleSelectionScreen());

      case AppRoutes.authGate:
        return _material(const AuthGateScreen());

      case AppRoutes.shell:
        final args = settings.arguments;
        final isDoctor = _readIsDoctor(args);
        return _material(isDoctor ? const MainLayoutDoctor() : const MainLayoutPatient());

      default:
        return _errorRoute(settings.name);
    }
  }

  static bool _readIsDoctor(Object? args) {
    if (args is ShellArgs) return args.isDoctor;
    if (args is Map) {
      final v = args['isDoctor'];
      if (v is bool) return v;
    }
    return false;
  }

  static MaterialPageRoute _material(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Route not found: ${routeName ?? "unknown"}'),
        ),
      ),
    );
  }
}