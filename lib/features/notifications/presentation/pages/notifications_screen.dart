import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/responsive/page_scaffold.dart';
import 'package:lung_diagnosis_app/core/responsive/responsive_shell.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/notifications/presentation/models/app_notification_item.dart';
import 'package:lung_diagnosis_app/features/notifications/presentation/widgets/notification_item_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<AppNotificationItem> mockNotifications = [
    AppNotificationItem(
      title: 'Daily breathing check',
      description:
          'Record today\'s cough sample to keep your health timeline up to date.',
      timeAgo: '10m ago',
      icon: Icons.mic_none_rounded,
      type: AppNotificationType.reminder,
    ),
    AppNotificationItem(
      title: 'X-ray analysis completed',
      description:
          'Your latest chest X-ray has been processed and the result is ready to review.',
      timeAgo: '28m ago',
      icon: Icons.analytics_outlined,
      type: AppNotificationType.result,
    ),
    AppNotificationItem(
      title: 'Doctor feedback received',
      description:
          'A specialist added notes to your latest diagnostic report.',
      timeAgo: '1h ago',
      icon: Icons.local_hospital_outlined,
      type: AppNotificationType.medical,
    ),
    AppNotificationItem(
      title: 'Medication reminder',
      description:
          'It\'s time for your scheduled medication. Open reminders to mark it done.',
      timeAgo: '2h ago',
      icon: Icons.medication_outlined,
      type: AppNotificationType.reminder,
    ),
    AppNotificationItem(
      title: 'New health article',
      description:
          'A new educational article about asthma prevention was added for you.',
      timeAgo: '4h ago',
      icon: Icons.menu_book_outlined,
      type: AppNotificationType.content,
    ),
    AppNotificationItem(
      title: 'Abnormal reading detected',
      description:
          'Your recent symptom trend needs attention. Review details or contact your doctor.',
      timeAgo: '6h ago',
      icon: Icons.warning_amber_rounded,
      type: AppNotificationType.alert,
    ),
    AppNotificationItem(
      title: 'Appointment reminder',
      description:
          'You have a follow-up consultation scheduled soon. Check time and preparation steps.',
      timeAgo: 'Yesterday',
      icon: Icons.event_note_rounded,
      type: AppNotificationType.schedule,
    ),
    AppNotificationItem(
      title: 'Profile completion suggestion',
      description:
          'Add your medical history to improve recommendations and report context.',
      timeAgo: 'Yesterday',
      icon: Icons.person_outline_rounded,
      type: AppNotificationType.account,
    ),
    AppNotificationItem(
      title: 'App update available',
      description:
          'A new version includes performance improvements and a smoother diagnosis flow.',
      timeAgo: '2d ago',
      icon: Icons.system_update_alt_rounded,
      type: AppNotificationType.system,
    ),
  ];

  Widget _emptyBody() {
    return PageScaffold(
      maxWidth: 900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: EmptyStateCard(
            icon: Icons.notifications_off_rounded,
            title: AppStrings.noNotifications,
            message: 'You’ll see reminders and updates here once available.',
          ),
        ),
      ),
    );
  }

  Widget _listBody() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: mockNotifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return NotificationItemCard(notification: mockNotifications[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = mockNotifications.isEmpty ? _emptyBody() : _listBody();

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.notification,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: ResponsiveShell(
          mobile: body,
          tablet: PageScaffold(maxWidth: 1100, child: body),
          desktop: PageScaffold(maxWidth: 1100, child: body),
        ),
      ),
    );
  }
}
