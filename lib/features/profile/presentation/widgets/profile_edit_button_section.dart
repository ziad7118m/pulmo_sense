import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';

class ProfileEditButtonSection extends StatelessWidget {
  final VoidCallback onPressed;

  const ProfileEditButtonSection({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: AppStrings.editProfile,
        onPressed: onPressed,
      ),
    );
  }
}
