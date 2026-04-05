import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';

class PatientAccessSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;

  const PatientAccessSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label = 'View patient dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : CustomButton(
              text: label,
              icon: Icons.arrow_forward_rounded,
              borderRadius: 18,
              onPressed: onPressed,
            ),
    );
  }
}
