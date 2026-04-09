import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/storage/app_storage.dart';
import 'package:lung_diagnosis_app/core/storage/keys.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/signup_otp_verification_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/login_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/verification_code_header.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/verification_resend_row.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';
import 'package:provider/provider.dart';

class SignupOtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isDoctor;

  const SignupOtpVerificationScreen({
    super.key,
    required this.email,
    required this.isDoctor,
  });

  @override
  State<SignupOtpVerificationScreen> createState() => _SignupOtpVerificationScreenState();
}

class _SignupOtpVerificationScreenState extends State<SignupOtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SignupOtpVerificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignupOtpVerificationController(
      repository: context.read<AuthRepository>(),
      email: widget.email,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _resendCode() async {
    final ok = await _controller.resendCode();
    if (!mounted) return;
    if (!ok) {
      AppTopMessage.error(context, _controller.error ?? 'Unable to resend OTP');
      return;
    }
    AppTopMessage.success(context, 'A new OTP has been sent to ${widget.email}');
  }

  Future<void> _verifyCode() async {
    final ok = await _controller.verify(_formKey);
    if (!mounted) return;
    if (!ok) {
      AppTopMessage.error(context, _controller.error ?? 'Invalid or expired OTP');
      return;
    }

    await AppStorage.remove(StorageKeys.pendingVerificationEmail);
    await AppStorage.remove(StorageKeys.pendingVerificationIsDoctor);

    if (!mounted) return;

    final accountType = widget.isDoctor ? 'doctor' : 'patient';
    AppTopMessage.success(
      context,
      'Email confirmed successfully. Your $accountType account is now pending admin approval.',
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Scaffold(
          appBar: CustomAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: '',
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const VerificationCodeHeader(),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      ),
                    ),
                    child: Text('Enter the 6-digit OTP sent to ${widget.email}'),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    labelText: 'OTP Code',
                    controller: _controller.codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    maxLines: 1,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.length != 6) {
                        return 'Please enter a valid 6-digit code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  VerificationResendRow(
                    canResend: _controller.canResend && !_controller.isLoading,
                    timer: _controller.timer,
                    onResend: _resendCode,
                  ),
                  const SizedBox(height: 40),
                  _controller.isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : CustomButton(
                          text: 'Verify OTP',
                          height: 48,
                          onPressed: _verifyCode,
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
