import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/auth_repository.dart';

class SignupOtpVerificationController extends ChangeNotifier {
  final AuthRepository _repository;
  final String email;

  SignupOtpVerificationController({
    required AuthRepository repository,
    required this.email,
  }) : _repository = repository {
    _startTimer();
  }

  final TextEditingController codeController = TextEditingController();

  int _timer = 60;
  bool _canResend = false;
  bool _isLoading = false;
  String? _error;
  Timer? _countdownTimer;

  int get timer => _timer;
  bool get canResend => _canResend;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool validate(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  Future<bool> resendCode() async {
    if (_isLoading || !_canResend) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.sendEmailOtp(email);

    _isLoading = false;
    result.when(
      success: (_) {
        _timer = 60;
        _canResend = false;
        _startTimer();
      },
      failure: (failure) => _error = failure.message,
    );
    notifyListeners();
    return result.isSuccess;
  }

  Future<bool> verify(GlobalKey<FormState> formKey) async {
    if (!validate(formKey) || _isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.verifyEmailOtp(
      email: email,
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
