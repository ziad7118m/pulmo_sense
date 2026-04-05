import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/di/app_di.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/forget_password_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/password_reset_flow_seed.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/code_verification_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';
import 'package:provider/provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ForgetPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ForgetPasswordController(context.read<PasswordResetRepository>());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final ok = await _controller.requestCode(_formKey);
    if (!mounted) return;

    if (!ok) {
      AppTopMessage.error(context, _controller.error ?? 'Unable to send verification code');
      return;
    }

    final challenge = _controller.lastChallenge;
    final seed = PasswordResetFlowSeed(
      emailOrPhone: _controller.emailOrPhoneController.text.trim(),
      deliveryHint: challenge?.deliveryHint.trim() ?? '',
      debugCode: _sanitizeDebugCode(challenge?.debugCode),
    );

    AppTopMessage.success(context, _buildSuccessMessage(seed));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CodeVerificationScreen(seed: seed),
      ),
    );
  }

  String _buildSuccessMessage(PasswordResetFlowSeed seed) {
    final parts = <String>['Verification code generated'];
    if (seed.hasDeliveryHint) {
      parts.add('Destination: ${seed.deliveryHint}');
    }
    if (seed.hasDebugCode) {
      parts.add('Dev code: ${seed.debugCode}');
    }
    return parts.join(' | ');
  }

  String? _sanitizeDebugCode(String? value) {
    final normalized = (value ?? '').trim();
    if (normalized.isEmpty) return null;
    if (!_canShowDebugCode) return null;
    return normalized;
  }

  bool get _canShowDebugCode => !AppDI.config.useApi && AppDI.config.isDev;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final viewData = _controller.viewData;
        return Scaffold(
          appBar: CustomAppBar(
            title: AppStrings.forgotPassword,
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
                    labelText: AppStrings.emailOrPhone,
                    controller: _controller.emailOrPhoneController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 40),
                  viewData.isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : CustomButton(
                          text: AppStrings.save,
                          onPressed: _sendCode,
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
