import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

class RoleSelectionHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBackTap;

  const RoleSelectionHeader({
    super.key,
    required this.isDark,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                onPressed: onBackTap,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? scheme.onSurface : scheme.primary,
                ),
                splashRadius: 22,
              ),
              const Spacer(),
              Text(
                'Pulmo Sense',
                style: TextStyle(
                  color: isDark ? scheme.onSurface : scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44),
            ],
          ),
        ),
        Center(
          child: Container(
            height: 92,
            width: 92,
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(isDark ? 0.18 : 0.9),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.7),
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/app_logo.png',
                height: 54,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.local_hospital,
                    size: 50,
                    color: scheme.primary,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          AppStrings.selectYourRole,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? scheme.onSurface : scheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.roleTitle,
          style: TextStyle(
            fontSize: 14,
            color: (isDark ? scheme.onSurface : scheme.onSurfaceVariant)
                .withOpacity(0.9),
            height: 1.25,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
