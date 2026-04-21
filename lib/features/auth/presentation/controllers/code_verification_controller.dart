import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/password_reset_challenge.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/code_verification_view_data.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/password_reset_flow_seed.dart';

class CodeVerificationController extends ChangeNotifier {
  final PasswordResetRepository _repository;
  final PasswordResetFlowSeed seed;

  CodeVerificationController({
    required PasswordResetRepository repository,
    required this.seed,
  }) : _repository = repository {
    _startTimer();
  }

  final TextEditingController codeController = TextEditingController();

  int _timer = 60;
  bool _canResend = false;
  bool _isLoading = false;
  String? _error;
  PasswordResetChallenge? _lastChallenge;
  Timer? _countdownTimer;

  CodeVerificationViewData get viewData => CodeVerificationViewData(
        timer: _timer,
        canResend: _canResend,
      );

  bool get isLoading => _isLoading;
  String? get error => _error;
  PasswordResetChallenge? get lastChallenge => _lastChallenge;

  bool validate(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  Future<bool> resendCode() async {
    if (_isLoading) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.requestCode(seed.emailOrPhone);

    _isLoading = false;
    result.when(
      success: (challenge) {
        _lastChallenge = challenge;
        _timer = 60;
        _canResend = false;
        _startTimer();
      },
      failure: (failure) => _error = failure.message,
    );
    notifyListeners();
    return result.isSuccess;
  }

  Future<bool> verifyCode(GlobalKey<FormState> formKey) async {
    if (!validate(formKey) || _isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.verifyCode(
      emailOrPhone: seed.emailOrPhone,
      code: codeController.text.trim(),
    );

    _isLoading = false;
    result.when(
      success: (_) {},
      failure: (failure) => _error = failure.message,
    );
    notifyListeners();
    return result.isSuccess;
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        _timer -= 1;
        notifyListeners();
        return;
      }
      if (!_canResend) {
        _canResend = true;
        notifyListeners();
      }
      timer.cancel();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    codeController.dispose();
    super.dispose();
  }
}
