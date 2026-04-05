import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';

class XrayAnalyzeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const XrayAnalyzeButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: CustomButton(
        text: AppStrings.analyze,
        onPressed: onPressed,
        width: double.infinity,
      ),
    );
  }
}
