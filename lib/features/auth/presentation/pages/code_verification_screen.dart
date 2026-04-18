import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/di/app_di.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/code_verification_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/password_reset_flow_seed.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/new_password_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/otp_code_input.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/verification_code_header.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/verification_resend_row.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';
import 'package:provider/provider.dart';

class CodeVerificationScreen extends StatefulWidget {
  final PasswordResetFlowSeed seed;

  const CodeVerificationScreen({
    super.key,
    required this.seed,
  });

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CodeVerificationController _controller;
  late PasswordResetFlowSeed _seed;
  bool _hasAutoSubmitted = false;

  @override
  void initState() {
    super.initState();
    _seed = _sanitizeSeed(widget.seed);
    _controller = CodeVerificationController(
      repository: context.read<PasswordResetRepository>(),
      seed: _seed,
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
      AppTopMessage.error(context, _controller.error ?? 'Unable to resend verification code');
      return;
    }

    final challenge = _controller.lastChallenge;
    final nextSeed = _seed.copyWith(
      deliveryHint: challenge?.deliveryHint.trim().isNotEmpty == true
          ? challenge!.deliveryHint.trim()
          : _seed.deliveryHint,
      debugCode: _sanitizeDebugCode(challenge?.debugCode),
    );

    setState(() {
      _seed = nextSeed;
      _hasAutoSubmitted = false;
      _controller.codeController.clear();
    });

    AppTopMessage.success(context, _buildResendMessage(nextSeed));
  }

  Future<void> _verifyCode() async {
    if (_controller.isLoading) return;

    final code = _controller.codeController.text.trim();
    if (code.length != 6) {
      AppTopMessage.error(context, 'Please enter a valid 6-digit code');
      return;
    }

    final ok = await _controller.verifyCode(_formKey);
    if (!mounted) return;
    if (!ok) {
      AppTopMessage.error(context, _controller.error ?? 'Verification failed');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewPasswordScreen(
          seed: _seed.copyWith(
            verificationCode: _controller.codeController.text.trim(),
          ),
        ),
      ),
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

  String _buildResendMessage(PasswordResetFlowSeed seed) {
    final parts = <String>['Verification code resent'];
    if (seed.hasDeliveryHint) {
      parts.add('Destination: ${seed.deliveryHint}');
    }
    if (seed.hasDebugCode) {
      parts.add('Dev code: ${seed.debugCode}');
    }
    return parts.join(' | ');
  }

  PasswordResetFlowSeed _sanitizeSeed(PasswordResetFlowSeed seed) {
    if (_canShowDebugCode) return seed;
    return seed.withoutDebugCode();
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
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final viewData = _controller.viewData;
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
                            'Enter the 6-digit code to continue resetting your password.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          if (_seed.hasDeliveryHint || _seed.hasDebugCode) ...[
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_seed.hasDeliveryHint)
                                    Text(
                                      'Sent to: ${_seed.deliveryHint}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      softWrap: true,
                                    ),
                                  if (_seed.hasDebugCode) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Dev code: ${_seed.debugCode}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          OtpCodeInput(
                            controller: _controller.codeController,
                            enabled: !_controller.isLoading,
                            onChanged: _handleCodeChanged,
                            onCompleted: _handleCodeCompleted,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'The code will verify automatically once all digits are entered.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 24),
                          VerificationResendRow(
                            canResend: viewData.canResend && !_controller.isLoading,
                            timer: viewData.timer,
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
                                  text: 'Verify code',
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
