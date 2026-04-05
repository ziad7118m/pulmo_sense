import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/banner_profile_summary_card.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/banner_profile_top_bar.dart';
import 'package:provider/provider.dart';

class BannerWithProfile extends StatelessWidget {
  final String backgroundImage;
  final String firstName;
  final bool isDoctor;
  final String title;
  final String subtitle;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final double height;
  final int notificationCount;

  const BannerWithProfile({
    super.key,
    required this.backgroundImage,
    required this.firstName,
    this.isDoctor = false,
    required this.title,
    required this.subtitle,
    this.onNotificationTap,
    this.onProfileTap,
    this.height = 300,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final avatarPath =
        (context.watch<ProfileController>().profile?.avatarPath ?? '').trim();
    final displayName = _resolveDisplayName();
    final headerTitle = title.trim().isEmpty ? 'Clinical assistant' : title.trim();
    final subtitleText =
        subtitle.trim().isEmpty ? _fallbackSubtitle : subtitle.trim();

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.58),
                    Colors.black.withOpacity(0.24),
                    Colors.black.withOpacity(0.56),
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BannerProfileTopBar(
                      avatarPath: avatarPath,
                      displayName: displayName,
                      isDoctor: isDoctor,
                      notificationCount: notificationCount,
                      onProfileTap: onProfileTap ??
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                      onNotificationTap: onNotificationTap ?? () {},
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: BannerProfileSummaryCard(
                            title: headerTitle,
                            subtitle: subtitleText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveDisplayName() {
    final trimmedFirstName = firstName.trim();
    if (trimmedFirstName.isEmpty) return AppStrings.welcome;
    return isDoctor ? 'DR $trimmedFirstName' : trimmedFirstName;
  }

  static const String _fallbackSubtitle =
      'Smart respiratory support for faster, clearer follow-up.';
}
