import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';

class SignupNameFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final String? Function(String?)? firstNameValidator;

  const SignupNameFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    this.firstNameValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            labelText: AppStrings.firstName,
            controller: firstNameController,
            validator: firstNameValidator,
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
