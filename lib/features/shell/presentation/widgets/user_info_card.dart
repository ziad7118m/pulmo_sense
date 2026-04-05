import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/helpers/user_info_resolver.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/user_info_header_section.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/user_info_mini_stat_card.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/user_info_readonly_row.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/models/user_info_data.dart';

class UserInfoCard extends StatelessWidget {
  final UserInfoData userData;
  final VoidCallback? onTap;

  const UserInfoCard({
    super.key,
    required this.userData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fullName = UserInfoResolver.fullName(userData);
    final avatarPath = userData.avatarPath.trim();
    final roleText = UserInfoResolver.normalizedValue(userData.roleText);
    final accountId = UserInfoResolver.normalizedValue(userData.accountId);
    final initials = UserInfoResolver.initials(fullName);

    final email = UserInfoResolver.normalizedValue(userData.email);
    final nationalId = UserInfoResolver.normalizedValue(userData.nationalId);
    final gender = UserInfoResolver.normalizedValue(userData.gender);
    final marital = UserInfoResolver.normalizedValue(userData.marital);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      scheme.surface,
                      scheme.surfaceVariant.withOpacity(0.84),
                    ]
                  : const [
                      Color(0xFF74B7FF),
                      Color(0xFF4E9EFF),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? scheme.outlineVariant.withOpacity(0.8)
                  : Colors.white.withOpacity(0.28),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, 10),
                color: Colors.black.withOpacity(isDark ? 0.18 : 0.08),
              ),
            ],
          ),
          child: IconTheme(
            data: IconThemeData(
              color: isDark ? scheme.onSurfaceVariant : Colors.white,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: isDark ? scheme.onSurface : Colors.white,
              ),
              child: Column(
                children: [
                  UserInfoHeaderSection(
                    fullName: fullName,
                    roleText: roleText,
                    accountId: accountId,
                    avatarPath: avatarPath,
                    initials: initials,
                    onTap: onTap,
                  ),
                  const SizedBox(height: 12),
                  UserInfoReadonlyRow(
                    icon: Icons.badge_outlined,
                    text: nationalId,
                    trailingLabel: AppStrings.nationalID,
                  ),
                  const SizedBox(height: 10),
                  UserInfoReadonlyRow(
                    icon: Icons.mail_outline_rounded,
                    text: email,
                    trailingLabel: 'Email',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: UserInfoMiniStatCard(
                          top: AppStrings.gender,
                          bottom: gender,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: UserInfoMiniStatCard(
                          top: AppStrings.maritalStatus,
                          bottom: marital,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
