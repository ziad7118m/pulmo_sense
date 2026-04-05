import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/local_account_status_view_data.dart';

class LocalAccountStatusController {
  final AuthController _authController;

  const LocalAccountStatusController({required AuthController authController})
    : _authController = authController;

  Future<void> logout() {
    return _authController.logout();
  }

  LocalAccountStatusViewData buildPendingViewData(BuildContext context) {
    return LocalAccountStatusViewData(
      title: 'Pending Approval',
      message: 'Your account is pending admin approval.\nPlease try again later.',
      icon: Icons.hourglass_top_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      useFilledButton: false,
    );
  }

  LocalAccountStatusViewData buildRejectedViewData() {
    return const LocalAccountStatusViewData(
      title: 'Account Rejected',
      message:
          'Your account request was rejected.\nPlease contact the admin if you think this is a mistake.',
      icon: Icons.block_outlined,
      iconColor: Color(0xFFB00020),
      useFilledButton: true,
    );
  }

  LocalAccountStatusViewData buildDisabledViewData() {
    return const LocalAccountStatusViewData(
      title: 'Account Disabled',
      message:
          'This account was disabled by the admin.\nIf you need access again, please contact support/admin.',
      icon: Icons.lock_outline,
      iconColor: Color(0xFFB00020),
      useFilledButton: true,
    );
  }
}
