import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';

class StethoscopeAnalyzeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StethoscopeAnalyzeButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: AppStrings.analyze,
      width: double.infinity,
      onPressed: onPressed,
    );
  }
}
