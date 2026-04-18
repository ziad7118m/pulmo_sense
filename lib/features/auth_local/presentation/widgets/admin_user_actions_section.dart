import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/controllers/admin_user_actions_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_status_badge.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';

class AdminUserActionsSection extends StatelessWidget {
  final AuthUser user;

  const AdminUserActionsSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    const actionsController = AdminUserActionsController();
    final scheme = Theme.of(context).colorScheme;
    final actions = <Widget>[];

    if (user.isDeleted) {
      actions.add(
        _ActionTile(
          title: 'Restore account',
          subtitle: 'Restore this deleted account using the live admin API.',
          icon: Icons.restore_rounded,
          color: scheme.primary,
          onTap: () => actionsController.restoreAccount(context, user: user),
        ),
      );
    }

    if (!user.isDeleted && user.status.isPending) {
      actions.addAll([
        _ActionTile(
          title: 'Approve account',
          subtitle: 'Approve this pending account and move it into the active queue.',
          icon: Icons.verified_rounded,
          color: scheme.primary,
          onTap: () => actionsController.approveAs(context, user: user, role: user.role),
        ),
        _ActionTile(
          title: 'Reject request',
          subtitle: 'Reject this signup request and keep it away from the active flow.',
          icon: Icons.block_rounded,
          color: const Color(0xFFE25563),
          onTap: () => actionsController.rejectAccount(context, user: user),
        ),
      ]);
    }

    if (!user.isDeleted && user.status.isApproved) {
      actions.add(
        _ActionTile(
          title: 'Disable account',
          subtitle: 'Temporarily block this account without deleting it.',
          icon: Icons.lock_outline_rounded,
          color: const Color(0xFF546E7A),
          onTap: () => actionsController.disableAccount(context, user: user),
        ),
      );
    }

    if (!user.isDeleted && user.status.isDisabled) {
      actions.add(
        _ActionTile(
          title: 'Enable account',
          subtitle: 'Restore this account and return it to the active list.',
          icon: Icons.lock_open_rounded,
          color: scheme.primary,
          onTap: () => actionsController.enableAccount(context, user: user),
        ),
      );
    }

    if (!user.isDeleted && user.status.isRejected) {
      actions.add(
        _ActionTile(
          title: 'Approve again',
          subtitle: 'Move this rejected account back to the active approved list.',
          icon: Icons.verified_rounded,
          color: scheme.primary,
          onTap: () => actionsController.approveAs(context, user: user, role: user.role),
        ),
      );
    }

    if (!user.isDeleted && !user.status.isPending) {
      actions.add(
        _ActionTile(
          title: 'Delete account',
          subtitle: 'Remove this account using the live admin API.',
          icon: Icons.delete_outline_rounded,
          color: const Color(0xFFE25563),
          onTap: () => actionsController.deleteAccount(context, user: user),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? scheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.admin_panel_settings_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin actions',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.isDeleted ? 'Current state: Deleted' : 'Current state: ${user.status.displayName}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              AdminStatusBadge(status: user.status),
            ],
          ),
          const SizedBox(height: 14),
          if (actions.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceVariant.withOpacity(0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'No state-change actions are available for this account right now.',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            )
          else
            ...actions.expand((action) => [action, const SizedBox(height: 10)]),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
