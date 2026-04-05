import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';

class EditProfileSaveSection extends StatelessWidget {
  final VoidCallback onSave;

  const EditProfileSaveSection({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: AppStrings.save,
        onPressed: onSave,
      ),
    );
  }
}
