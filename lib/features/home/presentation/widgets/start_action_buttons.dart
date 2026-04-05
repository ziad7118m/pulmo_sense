import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/login_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/role_selection_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';

class StartActionButtons extends StatelessWidget {
  const StartActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: AppStrings.signUp,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RoleSelectionScreen(),
                  ),
                );
              },
              height: 48,
              borderRadius: 8,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: CustomButton(
              text: AppStrings.login,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              height: 48,
              borderRadius: 8,
            ),
          ),
        ],
      ),
    );
  }
}
