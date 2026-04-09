import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/storage/app_storage.dart';
import 'package:lung_diagnosis_app/core/storage/keys.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/helpers/auth_destination_resolver.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/signup_otp_verification_screen.dart';
import 'package:provider/provider.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  Future<_PendingVerificationState> _readPendingState() async {
    final email = await AppStorage.getString(StorageKeys.pendingVerificationEmail);
    if (email == null || email.trim().isEmpty) {
      return const _PendingVerificationState.none();
    }

    final isDoctor = await AppStorage.getBool(
      StorageKeys.pendingVerificationIsDoctor,
    );

    return _PendingVerificationState(
      email: email.trim(),
      isDoctor: isDoctor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (_, auth, __) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.currentUser != null) {
          return resolveAuthDestination(auth.currentUser);
        }

        return FutureBuilder<_PendingVerificationState>(
          future: _readPendingState(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final pendingState = snapshot.data ?? const _PendingVerificationState.none();
            if (pendingState.hasPendingVerification) {
              return SignupOtpVerificationScreen(
                email: pendingState.email!,
                isDoctor: pendingState.isDoctor,
              );
            }

            return resolveAuthDestination(null);
          },
        );
      },
    );
  }
}

class _PendingVerificationState {
  final String? email;
  final bool isDoctor;

  const _PendingVerificationState({
    required this.email,
    required this.isDoctor,
  });

  const _PendingVerificationState.none()
      : email = null,
        isDoctor = false;

  bool get hasPendingVerification => email != null && email!.trim().isNotEmpty;
}
