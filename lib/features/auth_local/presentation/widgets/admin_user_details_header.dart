import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/utils/date_text_formatter.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_status_badge.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class AdminUserDetailsHeader extends StatelessWidget {
  final AuthUser user;
  final UserProfile profile;

  const AdminUserDetailsHeader({
    super.key,
    required this.user,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = profile.avatarPath.trim().isNotEmpty && File(profile.avatarPath).existsSync()
        ? FileImage(File(profile.avatarPath)) as ImageProvider
        : null;
    final completion = _profileCompletion(profile);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F4FB8), Color(0xFF3B8CFF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.18),
                backgroundImage: avatar,
                child: avatar == null
                    ? Text(
                        (user.displayName.isEmpty ? 'U' : user.displayName[0]).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName.isEmpty ? 'User' : user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _headerPill(user.role.displayName, Icons.badge_rounded),
                        _headerPill('Created ${formatIsoDateOnly(user.createdAt)}', Icons.calendar_today_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AdminStatusBadge(status: user.status),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Profile completion: $completion%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerPill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  int _profileCompletion(UserProfile profile) {
    final values = <String>[
      profile.nationalId,
      profile.address,
      profile.phone,
      profile.birthDate,
      profile.gender,
      profile.marital,
      profile.avatarPath,
      if (user.role.isDoctor) profile.doctorLicense,
    ];
    final filled = values.where((value) => value.trim().isNotEmpty).length;
    if (values.isEmpty) return 0;
    return ((filled / values.length) * 100).round();
  }
}
