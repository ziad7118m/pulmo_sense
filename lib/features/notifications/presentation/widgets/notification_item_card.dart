import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/notifications/presentation/models/app_notification_item.dart';

class NotificationItemCard extends StatelessWidget {
  final AppNotificationItem notification;

  const NotificationItemCard({
    super.key,
    required this.notification,
  });

  Color _iconBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (notification.type) {
      case AppNotificationType.alert:
        return Colors.orange.withOpacity(0.14);
      case AppNotificationType.result:
        return Colors.green.withOpacity(0.14);
      case AppNotificationType.medical:
        return Colors.red.withOpacity(0.12);
      case AppNotificationType.content:
        return Colors.blue.withOpacity(0.12);
      case AppNotificationType.system:
        return Colors.deepPurple.withOpacity(0.14);
      case AppNotificationType.schedule:
        return Colors.teal.withOpacity(0.14);
      case AppNotificationType.account:
        return scheme.primary.withOpacity(0.12);
      case AppNotificationType.reminder:
        return scheme.primary.withOpacity(0.10);
    }
  }

  Color _iconColor(BuildContext context) {
    switch (notification.type) {
      case AppNotificationType.alert:
        return Colors.orange.shade700;
      case AppNotificationType.result:
        return Colors.green.shade700;
      case AppNotificationType.medical:
        return Colors.red.shade700;
      case AppNotificationType.content:
        return Colors.blue.shade700;
      case AppNotificationType.system:
        return Colors.deepPurple.shade700;
      case AppNotificationType.schedule:
        return Colors.teal.shade700;
      case AppNotificationType.account:
      case AppNotificationType.reminder:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconBg = _iconBackground(context);
    final iconColor = _iconColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(notification.icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
