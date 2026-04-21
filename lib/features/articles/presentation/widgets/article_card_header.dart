import 'dart:io';

import 'package:flutter/material.dart';

class ArticleCardHeader extends StatelessWidget {
  final String doctorImage;
  final String doctorName;
  final bool showHiddenBadge;
  final bool isHiddenByAdmin;
  final bool showOwnerDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ArticleCardHeader({
    super.key,
    required this.doctorImage,
    required this.doctorName,
    required this.showHiddenBadge,
    required this.isHiddenByAdmin,
    required this.showOwnerDelete,
    this.onEdit,
    this.onDelete,
  });

  ImageProvider<Object>? _imageProvider(String path) {
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
    final provider = _imageProvider(doctorImage);
    final canShowOwnerMenu = showOwnerDelete && (onEdit != null || onDelete != null);

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: scheme.primary.withOpacity(0.12)),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primaryContainer,
            backgroundImage: provider,
            child: provider == null
                ? Icon(
                    Icons.person,
                    size: 18,
                    color: scheme.primary,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorName,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Medical article',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (showHiddenBadge && isHiddenByAdmin)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Hidden',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        if (canShowOwnerMenu)
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) {
              if (value == 'edit') {
                onEdit?.call();
              }
              if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (_) => [
              if (onEdit != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
              if (onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
            ],
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: scheme.surfaceVariant.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.more_horiz_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
