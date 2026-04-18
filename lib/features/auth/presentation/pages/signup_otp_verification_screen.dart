import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/storage/app_storage.dart';
import 'package:lung_diagnosis_app/core/storage/keys.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/signup_otp_verification_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/login_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/otp_code_input.dart';
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
  bool _hasAutoSubmitted = false;

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
    _controller.codeController.clear();
    setState(() => _hasAutoSubmitted = false);
    AppTopMessage.success(context, 'A new OTP has been sent to ${widget.email}');
  }

  Future<void> _verifyCode() async {
    if (_controller.isLoading) return;

    final code = _controller.codeController.text.trim();
    if (code.length != 6) {
      AppTopMessage.error(context, 'Please enter a valid 6-digit code');
      return;
    }

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

  void _handleCodeChanged(String value) {
    if (value.length < 6 && _hasAutoSubmitted) {
      setState(() => _hasAutoSubmitted = false);
    }
  }

  Future<void> _handleCodeCompleted(String value) async {
    if (_hasAutoSubmitted || _controller.isLoading) return;
    setState(() => _hasAutoSubmitted = true);
    await _verifyCode();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Scaffold(
          appBar: CustomAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: '',
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    24 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          const VerificationCodeHeader(),
                          const SizedBox(height: 16),
                          Text(
                            'Verify your email address to finish creating your account.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: scheme.primary.withOpacity(0.12),
                              ),
                            ),
                            child: Text(
                              'Enter the 6-digit OTP sent to ${widget.email}',
                              style: Theme.of(context).textTheme.bodyMedium,
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(height: 28),
                          OtpCodeInput(
                            controller: _controller.codeController,
                            enabled: !_controller.isLoading,
                            onChanged: _handleCodeChanged,
                            onCompleted: _handleCodeCompleted,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'We\'ll verify the code automatically once all 6 digits are entered.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 24),
                          VerificationResendRow(
                            canResend: _controller.canResend && !_controller.isLoading,
                            timer: _controller.timer,
                            onResend: _resendCode,
                          ),
                          const SizedBox(height: 28),
                          _controller.isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: scheme.primary,
                                  ),
                                )
                              : CustomButton(
                                  text: 'Verify OTP',
                                  height: 52,
                                  borderRadius: 16,
                                  onPressed: _verifyCode,
                                ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
