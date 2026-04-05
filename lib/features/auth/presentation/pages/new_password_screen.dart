import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/new_password_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/password_reset_flow_seed.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/login_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';
import 'package:provider/provider.dart';

class NewPasswordScreen extends StatefulWidget {
  final PasswordResetFlowSeed seed;

  const NewPasswordScreen({
    super.key,
    required this.seed,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final NewPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NewPasswordController(
      repository: context.read<PasswordResetRepository>(),
      seed: widget.seed,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    final ok = await _controller.submit(_formKey);
    if (!mounted) return;
    if (!ok) {
      AppTopMessage.error(context, _controller.error ?? 'Unable to reset password');
      return;
    }

    AppTopMessage.success(context, 'Password updated successfully');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final viewData = _controller.viewData;
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Set a new password',
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    labelText: 'New Password',
                    controller: _controller.newPasswordController,
                    obscureText: true,
                    validator: (value) =>
                        value != null && value.length >= 8
                            ? null
                            : 'Minimum 8 characters',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: 'Confirm new password',
                    controller: _controller.confirmPasswordController,
                    obscureText: true,
                    validator: (value) =>
                        value != null && value == _controller.newPasswordController.text
                            ? null
                            : 'Passwords do not match',
                  ),
                  const SizedBox(height: 40),
                  viewData.isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : CustomButton(
                          text: AppStrings.save,
                          onPressed: _savePassword,
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
