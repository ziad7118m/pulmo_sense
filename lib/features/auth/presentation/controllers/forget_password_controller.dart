import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/password_reset_challenge.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/forget_password_view_data.dart';

class ForgetPasswordController extends ChangeNotifier {
  final PasswordResetRepository _repository;

  ForgetPasswordController(this._repository);

  final TextEditingController emailOrPhoneController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  PasswordResetChallenge? _lastChallenge;

  ForgetPasswordViewData get viewData => ForgetPasswordViewData(
        isLoading: _isLoading,
      );

  String? get error => _error;
  PasswordResetChallenge? get lastChallenge => _lastChallenge;

  bool validate(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  Future<bool> requestCode(GlobalKey<FormState> formKey) async {
    if (!validate(formKey) || _isLoading) return false;

    _error = null;
    _lastChallenge = null;
    _isLoading = true;
    notifyListeners();

    final result = await _repository.requestCode(emailOrPhoneController.text.trim());

    _isLoading = false;
    result.when(
      success: (challenge) => _lastChallenge = challenge,
      failure: (failure) => _error = failure.message,
    );
    notifyListeners();
    return result.isSuccess;
  }

  @override
  void dispose() {
    emailOrPhoneController.dispose();
    super.dispose();
  }
}
