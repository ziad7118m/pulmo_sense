import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_confirmation_dialog.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';
import 'package:provider/provider.dart';

class AdminUserActionsController {
  const AdminUserActionsController();

  Future<void> approveAs(
    BuildContext context, {
    required AuthUser user,
    required UserRole role,
  }) async {
    final ok = await AppConfirmationDialog.show(
      context,
      title: 'Approve account?',
      message: role.isDoctor
          ? 'This will activate the account as a Doctor.'
          : 'This will activate the account as a Patient.',
      confirmLabel: 'Approve',
      cancelLabel: 'Cancel',
      icon: Icons.verified_rounded,
    );
    if (!ok) return;

    await _run(
      context,
      action: (ctrl) => ctrl.approve(user.id, role: role),
      successMessage: role.isDoctor ? 'Approved as doctor' : 'Approved as patient',
    );
  }

  Future<void> rejectAccount(BuildContext context, {required AuthUser user}) async {
    final ok = await AppConfirmationDialog.show(
      context,
      title: 'Reject account?',
      message: 'The user will stay outside the active flow until you approve again later.',
      confirmLabel: 'Reject',
      cancelLabel: 'Cancel',
      icon: Icons.block_rounded,
      isDestructive: true,
    );
    if (!ok) return;

    await _run(
      context,
      action: (ctrl) => ctrl.reject(user.id),
      successMessage: 'Account rejected',
    );
  }

  Future<void> disableAccount(BuildContext context, {required AuthUser user}) async {
    final ok = await AppConfirmationDialog.show(
      context,
      title: 'Disable account?',
      message: 'The user will lose access until you enable the account again.',
      confirmLabel: 'Disable',
      cancelLabel: 'Cancel',
      icon: Icons.lock_rounded,
      isDestructive: true,
    );
    if (!ok) return;

    await _run(
      context,
      action: (ctrl) => ctrl.disable(user.id),
      successMessage: 'Account disabled',
    );
  }

  Future<void> enableAccount(BuildContext context, {required AuthUser user}) async {
    final ok = await AppConfirmationDialog.show(
      context,
      title: 'Enable account?',
      message: 'This restores access and returns the account to the approved list.',
      confirmLabel: 'Enable',
      cancelLabel: 'Cancel',
      icon: Icons.lock_open_rounded,
    );
    if (!ok) return;

    await _run(
      context,
      action: (ctrl) => ctrl.enable(user.id),
      successMessage: 'Account enabled',
    );
  }

  Future<void> deleteAccount(BuildContext context, {required AuthUser user}) async {
    final ok = await AppConfirmationDialog.show(
      context,
      title: 'Delete account?',
      message: 'This will delete the user account and its saved profile data. This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.person_remove_alt_1_rounded,
    );
    if (!ok) return;

    await _run(
      context,
      action: (ctrl) => ctrl.deleteUser(user.id),
      successMessage: 'Account deleted',
    );
  }

  Future<void> _run(
    BuildContext context, {
    required Future<void> Function(AuthController controller) action,
    required String successMessage,
  }) async {
    try {
      final controller = context.read<AuthController>();
      await action(controller);
      if (!context.mounted) return;
      AppTopMessage.success(context, successMessage);
      Navigator.of(context).maybePop(true);
    } catch (_) {
      if (!context.mounted) return;
      AppTopMessage.error(context, context.read<AuthController>().error ?? 'Operation failed');
    }
  }
}
