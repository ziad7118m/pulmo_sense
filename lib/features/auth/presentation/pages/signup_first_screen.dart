import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/validators/account_validators.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/signup_profile_seed.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/auth_dropdown_field.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/auth_submit_section.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/signup_birth_date_fields.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/signup_name_fields.dart';

import 'signup_second_screen.dart';

class SignupFirstScreen extends StatefulWidget {
  final bool isDoctor;

  const SignupFirstScreen({super.key, required this.isDoctor});

  @override
  State<SignupFirstScreen> createState() => _SignupFirstScreenState();
}

class _SignupFirstScreenState extends State<SignupFirstScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nationalIDController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();

  String? _selectedGovernorate;
  String? _selectedGender;
  String? _selectedMaritalStatus;

  static const List<String> _egyptGovernorates = [
    'Cairo',
    'Alexandria',
    'Giza',
    'Dakahlia',
    'Sharkia',
    'Qalyubia',
    'Beheira',
    'Gharbia',
    'Monufia',
    'Kafr El Sheikh',
    'Fayoum',
    'Beni Suef',
    'Minya',
    'Asyut',
    'Sohag',
    'Qena',
    'Luxor',
    'Aswan',
    'Red Sea',
    'New Valley',
    'Matrouh',
    'North Sinai',
    'South Sinai',
    'Ismailia',
    'Suez',
    'Port Said',
    'Damietta',
  ];

  String? _birthDateValidator(String? _) {
    return AccountValidators.birthDateYMD(
      y: _yearController.text,
      m: _monthController.text,
      d: _dayController.text,
    );
  }

  SignupProfileSeed _buildSeed(DateTime birthDate) {
    final formattedBirthDate =
        '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';

    return SignupProfileSeed(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      nationalId: _nationalIDController.text.trim(),
      address: _selectedGovernorate ?? '',
      phone: _phoneController.text.trim().replaceAll(' ', ''),
      birthDate: formattedBirthDate,
      gender: _selectedGender ?? '',
      maritalStatus: _selectedMaritalStatus ?? '',
    );
  }

  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;

    final dt = AccountValidators.parseYMD(
      y: _yearController.text,
      m: _monthController.text,
      d: _dayController.text,
    );
    if (dt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid birth date')),
      );
      return;
    }

    final seed = _buildSeed(dt);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupSecondScreen(
          isDoctor: widget.isDoctor,
          profileSeed: seed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppStrings.welcome,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              SignupNameFields(
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                firstNameValidator: AccountValidators.name,
                lastNameValidator: AccountValidators.name,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: AppStrings.nationalID,
                controller: _nationalIDController,
                keyboardType: TextInputType.number,
                validator: AccountValidators.nationalId,
              ),
              const SizedBox(height: 16),
              AuthDropdownField(
                value: _selectedGovernorate,
                hint: AppStrings.selectGovernorate,
                items: _egyptGovernorates,
                onChanged: (value) => setState(() => _selectedGovernorate = value),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Governorate is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: AppStrings.phoneNum,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: AccountValidators.egyptPhone,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.birthDate,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              SignupBirthDateFields(
                yearController: _yearController,
                monthController: _monthController,
                dayController: _dayController,
                validator: _birthDateValidator,
              ),
              const SizedBox(height: 24),
              AuthDropdownField(
                value: _selectedGender,
                hint: AppStrings.selectGender,
                items: const [AppStrings.male, AppStrings.female],
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Gender is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AuthDropdownField(
                value: _selectedMaritalStatus,
                hint: AppStrings.marriage,
                items: const [AppStrings.yes, AppStrings.no],
                onChanged: (value) =>
                    setState(() => _selectedMaritalStatus = value),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Marital status is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              AuthSubmitSection(
                isLoading: false,
                text: AppStrings.next,
                onPressed: _nextStep,
                borderRadius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nationalIDController.dispose();
    _phoneController.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }
}
