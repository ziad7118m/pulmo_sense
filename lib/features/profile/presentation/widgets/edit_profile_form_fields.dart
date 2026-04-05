import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/edit_profile_name_fields.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/edit_profile_status_row.dart';

class EditProfileFormFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController nationalIdController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController birthDateController;
  final TextEditingController licenseController;
  final String gender;
  final String maritalStatus;
  final bool isDoctor;
  final VoidCallback onBirthDateTap;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onMaritalStatusChanged;

  const EditProfileFormFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.nationalIdController,
    required this.addressController,
    required this.phoneController,
    required this.birthDateController,
    required this.licenseController,
    required this.gender,
    required this.maritalStatus,
    required this.isDoctor,
    required this.onBirthDateTap,
    required this.onGenderChanged,
    required this.onMaritalStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditProfileNameFields(
          firstNameController: firstNameController,
          lastNameController: lastNameController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: AppStrings.nationalID,
          controller: nationalIdController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: AppStrings.place,
          controller: addressController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: AppStrings.phoneNumber,
          controller: phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onBirthDateTap,
          child: AbsorbPointer(
            child: CustomTextField(
              labelText: AppStrings.date,
              controller: birthDateController,
            ),
          ),
        ),
        const SizedBox(height: 16),
        EditProfileStatusRow(
          gender: gender,
          maritalStatus: maritalStatus,
          onGenderChanged: onGenderChanged,
          onMaritalStatusChanged: onMaritalStatusChanged,
        ),
        if (isDoctor) ...[
          const SizedBox(height: 16),
          CustomTextField(
            labelText: AppStrings.licenceNumber,
            controller: licenseController,
          ),
        ],
      ],
    );
  }
}
