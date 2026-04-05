import 'dart:io';

import 'package:flutter/material.dart';

class DoctorPatientResolvedCard extends StatelessWidget {
  final String? resolvedName;
  final String resolvedId;
  final String? resolvedAvatarPath;

  const DoctorPatientResolvedCard({
    super.key,
    required this.resolvedName,
    required this.resolvedId,
    required this.resolvedAvatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final avatarPath = resolvedAvatarPath?.trim();
    final hasAvatar = avatarPath != null && avatarPath.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withOpacity(0.14),
            scheme.primaryContainer.withOpacity(0.32),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(2.2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.72),
            ),
            child: CircleAvatar(
              backgroundColor: scheme.primary.withOpacity(0.12),
              backgroundImage: hasAvatar ? FileImage(File(avatarPath)) : null,
              child: hasAvatar
                  ? null
                  : Icon(Icons.person_rounded, color: scheme.primary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolvedName?.trim().isNotEmpty == true
                      ? resolvedName!.trim()
                      : 'Patient selected',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${resolvedId.trim()}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_rounded, color: scheme.primary),
        ],
      ),
    );
  }
}
