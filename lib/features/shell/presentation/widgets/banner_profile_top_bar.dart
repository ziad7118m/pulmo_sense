import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/svg_icon_circle.dart';

class BannerProfileTopBar extends StatelessWidget {
  final String avatarPath;
  final String displayName;
  final bool isDoctor;
  final int notificationCount;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;

  const BannerProfileTopBar({
    super.key,
    required this.avatarPath,
    required this.displayName,
    required this.isDoctor,
    required this.notificationCount,
    required this.onProfileTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAvatar = avatarPath.isNotEmpty && File(avatarPath).existsSync();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onProfileTap,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withOpacity(0.85),
                          scheme.primary,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor:
                            scheme.primaryContainer.withOpacity(0.55),
                        backgroundImage:
                            hasAvatar ? FileImage(File(avatarPath)) : null,
                        child: hasAvatar
                            ? null
                            : Icon(
                                Icons.person,
                                color: scheme.primary,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName.trim().isEmpty ? 'User' : displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDoctor ? 'Doctor account' : 'Patient account',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              SvgIconCircle(
                svgPath: 'assets/icons/notification.svg',
                onTap: onNotificationTap,
              ),
              if (notificationCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5B6E),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    child: Text(
                      notificationCount > 99 ? '99+' : '$notificationCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
}
