import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';

class EditProfileNameFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const EditProfileNameFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            labelText: AppStrings.firstName,
            controller: firstNameController,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextField(
            labelText: AppStrings.lastName,
            controller: lastNameController,
          ),
        ),
      ],
    );
  }
}
