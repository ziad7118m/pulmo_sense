import 'dart:io';

import 'package:flutter/material.dart';

class ArticleAuthorHeader extends StatelessWidget {
  final String doctorName;
  final String doctorImagePath;
  final String createdAtText;
  final bool isHiddenByAdmin;

  const ArticleAuthorHeader({
    super.key,
    required this.doctorName,
    required this.doctorImagePath,
    required this.createdAtText,
    required this.isHiddenByAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = doctorImagePath.trim().isNotEmpty &&
        File(doctorImagePath).existsSync();

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: scheme.primaryContainer,
          backgroundImage: hasImage ? FileImage(File(doctorImagePath)) : null,
          child: hasImage ? null : Icon(Icons.person, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctorName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Text(
              createdAtText,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            if (isHiddenByAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Hidden by admin',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
