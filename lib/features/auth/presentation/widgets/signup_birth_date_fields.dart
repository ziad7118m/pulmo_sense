import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';

class SignupBirthDateFields extends StatelessWidget {
  final TextEditingController yearController;
  final TextEditingController monthController;
  final TextEditingController dayController;
  final String? Function(String?) validator;

  const SignupBirthDateFields({
    super.key,
    required this.yearController,
    required this.monthController,
    required this.dayController,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomTextField(
            labelText: AppStrings.year,
            controller: yearController,
            keyboardType: TextInputType.number,
            validator: validator,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomTextField(
            labelText: AppStrings.month,
            controller: monthController,
            keyboardType: TextInputType.number,
            validator: validator,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomTextField(
            labelText: AppStrings.day,
            controller: dayController,
            keyboardType: TextInputType.number,
            validator: validator,
          ),
        ),
      ],
    );
  }
}
