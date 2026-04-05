import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/banner_with_profile.dart';

class HomeProfileBanner extends StatelessWidget {
  final String firstName;
  final bool isDoctor;
  final VoidCallback? onNotificationTap;
  final int? notificationCount;

  const HomeProfileBanner({
    super.key,
    required this.firstName,
    required this.isDoctor,
    this.onNotificationTap,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return BannerWithProfile(
      backgroundImage: 'assets/images/expert_care.png',
      firstName: firstName,
      isDoctor: isDoctor,
      title: AppStrings.homeTitle,
      subtitle: AppStrings.homeSubtitle,
      onNotificationTap: onNotificationTap ?? () {},
      notificationCount:
          notificationCount ?? NotificationsScreen.mockNotifications.length,
    );
  }
}
