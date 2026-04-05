import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/signup_first_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/role_option_card.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/role_selection_header.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/role_selection_note_card.dart';
import 'package:lung_diagnosis_app/routes/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _buildBackgroundColors(theme, isDark),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              RoleSelectionHeader(
                isDark: isDark,
                onBackTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RoleOptionCard(
                        title: AppStrings.doctor,
                        icon: Icons.medical_services_rounded,
                        description: AppStrings.doctorRole,
                        isDark: isDark,
                        onTap: () => _openSignup(context, isDoctor: true),
                      ),
                      const SizedBox(height: 14),
                      RoleOptionCard(
                        title: AppStrings.patient,
                        icon: Icons.person_rounded,
                        description: AppStrings.patientRole,
                        isDark: isDark,
                        onTap: () => _openSignup(context, isDoctor: false),
                      ),
                      const SizedBox(height: 22),
                      RoleSelectionNoteCard(isDark: isDark),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          },
                          child: Text(
                            AppStrings.haveAccount,
                            style: TextStyle(
                              color: isDark
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.primary,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                              decorationColor: isDark
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _buildBackgroundColors(ThemeData theme, bool isDark) {
    final scheme = theme.colorScheme;
    if (isDark) {
      return <Color>[
        scheme.primary.withOpacity(0.95),
        scheme.secondary.withOpacity(0.65),
        scheme.surface,
      ];
    }
    return <Color>[
      scheme.surface,
      scheme.primaryContainer,
      scheme.secondaryContainer,
    ];
  }

  void _openSignup(BuildContext context, {required bool isDoctor}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupFirstScreen(isDoctor: isDoctor),
      ),
    );
  }
}
