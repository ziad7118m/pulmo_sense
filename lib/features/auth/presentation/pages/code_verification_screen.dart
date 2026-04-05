import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/di/app_di.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/code_verification_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/password_reset_flow_seed.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/new_password_screen.dart';
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
    });

    AppTopMessage.success(context, _buildResendMessage(nextSeed));
  }

  Future<void> _verifyCode() async {
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
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const VerificationCodeHeader(),
                  if (_seed.hasDeliveryHint || _seed.hasDebugCode) ...[
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_seed.hasDeliveryHint) Text('Sent to: ${_seed.deliveryHint}'),
                          if (_seed.hasDebugCode) ...[
                            const SizedBox(height: 6),
                            Text('Dev code: ${_seed.debugCode}'),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  CustomTextField(
                    labelText: 'Verification Code',
                    controller: _controller.codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 6) {
                        return 'Please enter a valid 6-digit code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  VerificationResendRow(
                    canResend: viewData.canResend && !_controller.isLoading,
                    timer: viewData.timer,
                    onResend: _resendCode,
                  ),
                  const SizedBox(height: 40),
                  _controller.isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : CustomButton(
                          text: 'Send',
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
