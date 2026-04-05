import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/helpers/auth_destination_resolver.dart';
import 'package:provider/provider.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (_, auth, __) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return resolveAuthDestination(auth.currentUser);
      },
    );
  }
}
