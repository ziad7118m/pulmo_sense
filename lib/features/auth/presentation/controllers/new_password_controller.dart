import 'package:flutter/widgets.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/new_password_view_data.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/password_reset_flow_seed.dart';

class NewPasswordController extends ChangeNotifier {
  final PasswordResetRepository _repository;
  final PasswordResetFlowSeed seed;

  NewPasswordController({
    required PasswordResetRepository repository,
    required this.seed,
  }) : _repository = repository;

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  NewPasswordViewData get viewData => NewPasswordViewData(isLoading: _isLoading);
  String? get error => _error;

  bool validate(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  Future<bool> submit(GlobalKey<FormState> formKey) async {
    if (!validate(formKey) || _isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.resetPassword(
      emailOrPhone: seed.emailOrPhone,
      code: seed.verificationCode ?? '',
      newPassword: newPasswordController.text,
    );

    _isLoading = false;
    result.when(
      success: (_) {},
      failure: (failure) => _error = failure.message,
    );
    notifyListeners();
    return result.isSuccess;
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
