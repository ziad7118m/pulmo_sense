import 'dart:io';

import 'package:flutter/material.dart';

class MenuProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String avatarPath;
  final VoidCallback onTap;

  const MenuProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.avatarPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAvatar = avatarPath.trim().isNotEmpty && File(avatarPath).existsSync();

    final gradientColors = isDark
        ? const [
            Color(0xFF0F4C81),
            Color(0xFF1565C0),
            Color(0xFF1E88E5),
          ]
        : const [
            Color(0xFF42A5F5),
            Color(0xFF1E88E5),
            Color(0xFF1976D2),
          ];

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withOpacity(isDark ? 0.20 : 0.16),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.08 : 0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 1.2,
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                backgroundImage: hasAvatar ? FileImage(File(avatarPath)) : null,
                child: hasAvatar
                    ? null
                    : Text(
                        (name.isEmpty ? 'U' : name[0]).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'User Account' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email.isEmpty ? '-' : email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.96),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
