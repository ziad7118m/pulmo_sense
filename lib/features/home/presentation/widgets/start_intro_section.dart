import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

class StartIntroSection extends StatelessWidget {
  const StartIntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            AppStrings.startTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            AppStrings.startSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: scheme.primary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
