import 'dart:io';

import 'package:flutter/material.dart';

class AddArticleAuthorCard extends StatelessWidget {
  final String doctorName;
  final String avatarPath;
  final VoidCallback onAddImages;

  const AddArticleAuthorCard({
    super.key,
    required this.doctorName,
    required this.avatarPath,
    required this.onAddImages,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAvatar =
        avatarPath.trim().isNotEmpty && File(avatarPath).existsSync();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: scheme.primaryContainer,
            backgroundImage: hasAvatar ? FileImage(File(avatarPath)) : null,
            child: hasAvatar ? null : Icon(Icons.person, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create a medical article with image preview before posting.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAddImages,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: const Text('Images'),
          ),
        ],
      ),
    );
  }
}
