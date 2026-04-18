import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/utils/date_text_formatter.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_status_badge.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class AdminUserCard extends StatelessWidget {
  final AuthUser user;
  final Widget badge;
  final List<Widget> actions;
  final VoidCallback? onTap;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.badge,
    required this.actions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? scheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    (user.displayName.trim().isEmpty ? '?' : user.displayName.trim()[0]).toUpperCase(),
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName.trim().isEmpty ? 'Unnamed user' : user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  badge,
                  const SizedBox(height: 8),
                  if (user.isDeleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Deleted',
                        style: TextStyle(
                          color: Color(0xFF8E24AA),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    )
                  else
                    AdminStatusBadge(status: user.status, compact: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(
                context,
                icon: user.role.isDoctor ? Icons.medical_services_rounded : Icons.person_outline_rounded,
                label: user.role.displayName,
              ),
              _metaChip(
                context,
                icon: Icons.calendar_today_rounded,
                label: formatIsoDateOnly(user.createdAt),
              ),
              _metaChip(
                context,
                icon: Icons.fingerprint_rounded,
                label: '#${user.id}',
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: actions,
            ),
          ],
          if (onTap != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Open details',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 18, color: scheme.primary),
              ],
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: card,
    );
  }

  Widget _metaChip(BuildContext context, {required IconData icon, required String label}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminRoleBadge extends StatelessWidget {
  final UserRole role;

  const AdminRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    late final Color background;
    late final Color foreground;
    late final IconData icon;

    switch (role) {
      case UserRole.doctor:
        background = const Color(0xFFE0F7F7);
        foreground = const Color(0xFF0F8B8D);
        icon = Icons.medical_services_rounded;
        break;
      case UserRole.patient:
        background = scheme.primaryContainer.withOpacity(0.9);
        foreground = scheme.primary;
        icon = Icons.person_rounded;
        break;
      case UserRole.admin:
        background = const Color(0xFFEDE7F6);
        foreground = const Color(0xFF5E35B1);
        icon = Icons.admin_panel_settings_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            role.displayName,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
