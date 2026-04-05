import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';

class AdminStatusBadge extends StatelessWidget {
  final UserAccountStatus status;
  final bool compact;

  const AdminStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    late final Color background;
    late final Color foreground;
    late final IconData icon;

    switch (status) {
      case UserAccountStatus.pending:
        background = const Color(0xFFFFF3DB);
        foreground = const Color(0xFF9A6700);
        icon = Icons.hourglass_top_rounded;
        break;
      case UserAccountStatus.approved:
        background = scheme.primaryContainer.withOpacity(0.9);
        foreground = scheme.primary;
        icon = Icons.verified_rounded;
        break;
      case UserAccountStatus.rejected:
        background = const Color(0xFFFFE4E8);
        foreground = const Color(0xFFC62828);
        icon = Icons.block_rounded;
        break;
      case UserAccountStatus.disabled:
        background = const Color(0xFFE8ECF3);
        foreground = const Color(0xFF455A64);
        icon = Icons.lock_rounded;
        break;
    }

    final vertical = compact ? 5.0 : 6.0;
    final horizontal = compact ? 8.0 : 10.0;
    final fontSize = compact ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            status.displayName,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
