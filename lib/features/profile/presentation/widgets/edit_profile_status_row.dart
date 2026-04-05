import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

class EditProfileStatusRow extends StatelessWidget {
  final String gender;
  final String maritalStatus;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onMaritalStatusChanged;

  const EditProfileStatusRow({
    super.key,
    required this.gender,
    required this.maritalStatus,
    required this.onGenderChanged,
    required this.onMaritalStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: gender,
            decoration: InputDecoration(
              labelText: AppStrings.gender,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [AppStrings.male, AppStrings.female]
                .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                .toList(),
            onChanged: onGenderChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: maritalStatus,
            decoration: InputDecoration(
              labelText: AppStrings.marriage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [AppStrings.yes, AppStrings.no]
                .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                .toList(),
            onChanged: onMaritalStatusChanged,
          ),
        ),
      ],
    );
  }
}
