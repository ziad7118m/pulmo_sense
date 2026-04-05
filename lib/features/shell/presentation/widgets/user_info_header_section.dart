import 'dart:io';

import 'package:flutter/material.dart';

class UserInfoHeaderSection extends StatelessWidget {
  final String fullName;
  final String roleText;
  final String accountId;
  final String avatarPath;
  final String initials;
  final VoidCallback? onTap;

  const UserInfoHeaderSection({
    super.key,
    required this.fullName,
    required this.roleText,
    required this.accountId,
    required this.avatarPath,
    required this.initials,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAvatar = avatarPath.isNotEmpty && File(avatarPath).existsSync();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UserInfoAvatar(
          hasAvatar: hasAvatar,
          avatarPath: avatarPath,
          initials: initials,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                roleText,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.surfaceVariant.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.55),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fingerprint_rounded,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ID: $accountId',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 6),
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: scheme.surfaceVariant.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.65),
              ),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _UserInfoAvatar extends StatelessWidget {
  final bool hasAvatar;
  final String avatarPath;
  final String initials;

  const _UserInfoAvatar({
    required this.hasAvatar,
    required this.avatarPath,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (hasAvatar) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(
          File(avatarPath),
          width: 54,
          height: 54,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.55)),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }
}
