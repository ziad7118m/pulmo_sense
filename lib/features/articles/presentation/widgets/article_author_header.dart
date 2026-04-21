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

  ImageProvider<Object>? _provider(String path) {
    final normalized = path.trim();
    if (normalized.isEmpty) return null;
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return NetworkImage(normalized);
    }
    if (normalized.startsWith('assets/')) {
      return AssetImage(normalized);
    }
    if (File(normalized).existsSync()) {
      return FileImage(File(normalized));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = _provider(doctorImagePath);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: scheme.primaryContainer,
          backgroundImage: provider,
          child: provider == null ? Icon(Icons.person, color: scheme.primary) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                doctorName,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                createdAtText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              if (isHiddenByAdmin)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Hidden by admin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
