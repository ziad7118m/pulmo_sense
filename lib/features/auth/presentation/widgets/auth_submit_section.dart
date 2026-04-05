import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';

class AuthSubmitSection extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double? borderRadius;

  const AuthSubmitSection({
    super.key,
    required this.isLoading,
    required this.text,
    required this.onPressed,
    this.height = 48,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : CustomButton(
              text: text,
              onPressed: onPressed,
              height: height,
              borderRadius: borderRadius,
            ),
    );
  }
}
