import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/helpers/admin_users_copy.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_users_kind.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_action_button.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';
import 'package:provider/provider.dart';

class AdminUsersPageController extends ChangeNotifier {
  String _query = '';
  AdminUsersRoleScope _roleScope = AdminUsersRoleScope.all;

  String get query => _query;
  AdminUsersRoleScope get roleScope => _roleScope;

  void setQuery(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == _query) return;
    _query = normalized;
    notifyListeners();
  }

  void setRoleScope(AdminUsersRoleScope value) {
    if (value == _roleScope) return;
    _roleScope = value;
    notifyListeners();
  }

  bool showRoleFilter(AdminUsersKind kind) {
    return kind != AdminUsersKind.doctors && kind != AdminUsersKind.patients;
  }

  bool matchesRoleScope(AuthUser user, AdminUsersKind kind) {
    if (!showRoleFilter(kind)) return true;

    switch (_roleScope) {
      case AdminUsersRoleScope.all:
        return true;
      case AdminUsersRoleScope.doctors:
        return user.role.isDoctor;
      case AdminUsersRoleScope.patients:
        return user.role.isPatient;
    }
  }

  Future<void> runUserAction(
    BuildContext context, {
    required Future<void> Function(AuthController controller) action,
    required String message,
    bool isError = false,
  }) async {
    final controller = context.read<AuthController>();

    try {
      await action(controller);
      if (!context.mounted) return;

      if (isError) {
        AppTopMessage.error(context, message);
      } else {
        AppTopMessage.success(context, message);
      }

      notifyListeners();
    } catch (_) {
      if (!context.mounted) return;
      AppTopMessage.error(context, controller.error ?? 'Operation failed');
    }
  }

  List<Widget> buildActions(
    BuildContext context, {
    required AdminUsersKind kind,
    required AuthUser user,
    required AuthController authController,
  }) {
    switch (kind) {
      case AdminUsersKind.pending:
        return _buildPendingActions(context, user);
      case AdminUsersKind.active:
      case AdminUsersKind.doctors:
      case AdminUsersKind.patients:
        return _buildDisableOnlyActions(context, user);
      case AdminUsersKind.disabled:
        return [
          AdminActionButton(
            text: 'Enable',
            icon: Icons.lock_open_rounded,
            isFilled: true,
            onTap: () => runUserAction(
              context,
              action: (controller) => controller.enable(user.id),
              message: 'Enabled ${user.email}',
            ),
          ),
        ];
      case AdminUsersKind.rejected:
        return [
          AdminActionButton(
            text: 'Approve',
            icon: Icons.verified_rounded,
            isFilled: true,
            onTap: () => runUserAction(
              context,
              action: (controller) => controller.approve(user.id, role: user.role),
              message: 'Approved ${user.email}',
            ),
          ),
        ];
    }
  }

  List<Widget> _buildPendingActions(BuildContext context, AuthUser user) {
    final actions = <Widget>[];

    if (user.role.isDoctor) {
      actions.addAll([
        AdminActionButton(
          text: 'Approve Doctor',
          icon: Icons.verified_rounded,
          isFilled: true,
          onTap: () => runUserAction(
            context,
            action: (controller) => controller.approve(user.id, role: UserRole.doctor),
            message: 'Approved ${user.email} as Doctor',
          ),
        ),
        AdminActionButton(
          text: 'Approve Patient',
          icon: Icons.person_rounded,
          onTap: () => runUserAction(
            context,
            action: (controller) => controller.approve(user.id, role: UserRole.patient),
            message: 'Approved ${user.email} as Patient',
          ),
        ),
      ]);
    } else {
      actions.add(
        AdminActionButton(
          text: 'Approve',
          icon: Icons.verified_rounded,
          isFilled: true,
          onTap: () => runUserAction(
            context,
            action: (controller) => controller.approve(user.id, role: UserRole.patient),
            message: 'Approved ${user.email}',
          ),
        ),
      );
    }

    actions.addAll([
      AdminActionButton(
        text: 'Reject',
        icon: Icons.block_rounded,
        isDanger: true,
        onTap: () => runUserAction(
          context,
          action: (controller) => controller.reject(user.id),
          message: 'Rejected ${user.email}',
          isError: true,
        ),
      ),
      AdminActionButton(
        text: 'Disable',
        icon: Icons.lock_rounded,
        isDanger: true,
        onTap: () => runUserAction(
          context,
          action: (controller) => controller.disable(user.id),
          message: 'Disabled ${user.email}',
          isError: true,
        ),
      ),
    ]);

    return actions;
  }

  List<Widget> _buildDisableOnlyActions(BuildContext context, AuthUser user) {
    return [
      AdminActionButton(
        text: 'Disable',
        icon: Icons.lock_rounded,
        isDanger: true,
        onTap: () => runUserAction(
          context,
          action: (controller) => controller.disable(user.id),
          message: 'Disabled ${user.email}',
          isError: true,
        ),
      ),
    ];
  }

  String heroTitle(AdminUsersKind kind) => AdminUsersCopy.heroTitle(kind);

  String heroSubtitle(AdminUsersKind kind) => AdminUsersCopy.heroSubtitle(kind);
}

enum AdminUsersRoleScope { all, doctors, patients }

extension AdminUsersRoleScopeX on AdminUsersRoleScope {
  String get label {
    switch (this) {
      case AdminUsersRoleScope.all:
        return 'All roles';
      case AdminUsersRoleScope.doctors:
        return 'Doctors';
      case AdminUsersRoleScope.patients:
        return 'Patients';
    }
  }
}
