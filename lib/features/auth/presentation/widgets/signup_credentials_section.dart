import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';

class SignupCredentialsSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController licenseController;
  final String? Function(String?)? emailValidator;
  final String? Function(String?)? passwordValidator;
  final String? Function(String?)? confirmPasswordValidator;
  final String? Function(String?)? licenseValidator;
  final bool isDoctor;

  const SignupCredentialsSection({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.licenseController,
    required this.emailValidator,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
    required this.licenseValidator,
    required this.isDoctor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          labelText: AppStrings.email,
          controller: emailController,
          validator: emailValidator,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: AppStrings.password,
          controller: passwordController,
          obscureText: true,
          validator: passwordValidator,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: AppStrings.confirmPassword,
          controller: confirmPasswordController,
          obscureText: true,
          validator: confirmPasswordValidator,
        ),
        if (isDoctor) ...[
          const SizedBox(height: 16),
          CustomTextField(
            labelText: AppStrings.licenceNumber,
            controller: licenseController,
            validator: licenseValidator,
          ),
        ],
      ],
    );
  }
}
