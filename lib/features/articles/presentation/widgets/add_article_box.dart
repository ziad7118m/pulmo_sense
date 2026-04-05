import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

class StatusBox extends StatelessWidget {
  final String profileImagePath;
  final String? uploadIconPath;
  final Widget? uploadIconWidget;
  final VoidCallback? onTap;

  const StatusBox({
    super.key,
    required this.profileImagePath,
    this.uploadIconPath,
    this.uploadIconWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool hasAvatar = profileImagePath.trim().isNotEmpty &&
        (profileImagePath.startsWith('assets/') ||
            File(profileImagePath).existsSync());

    final ImageProvider<Object>? avatarProvider = hasAvatar
        ? (profileImagePath.startsWith('assets/')
            ? (AssetImage(profileImagePath) as ImageProvider<Object>)
            : (FileImage(File(profileImagePath)) as ImageProvider<Object>))
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      scheme.surface,
                      scheme.surfaceVariant.withOpacity(0.92),
                    ]
                  : const [
                      Color(0xFFF3F8FF),
                      Color(0xFFE4F0FF),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? scheme.outlineVariant.withOpacity(0.75)
                  : const Color(0xFFB6D4FF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.22 : 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withOpacity(0.88),
                      scheme.secondary.withOpacity(0.92),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundColor: scheme.primaryContainer.withOpacity(0.85),
                    backgroundImage: avatarProvider,
                    child: avatarProvider != null
                        ? null
                        : Icon(
                            Icons.person,
                            color: scheme.primary,
                            size: 24,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a medical article',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.postPlaceholder,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.primary.withOpacity(0.18)
                      : Colors.white.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? scheme.primary.withOpacity(0.32)
                        : const Color(0xFFC7DEFF),
                  ),
                ),
                child: uploadIconWidget ??
                    (uploadIconPath != null
                        ? Image.asset(
                            uploadIconPath!,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.edit_note_rounded,
                            color: scheme.primary,
                            size: 24,
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
