import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/fullscreen_image_view.dart';

class DashboardExamHeader extends StatelessWidget {
  final String title;
  final String typeLabel;
  final IconData icon;
  final bool hasItem;
  final String? imagePath;

  const DashboardExamHeader({
    super.key,
    required this.title,
    required this.typeLabel,
    required this.icon,
    required this.hasItem,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: scheme.primaryContainer,
          ),
          child: Icon(icon, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.1,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                typeLabel,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (hasItem) ...[
          _DashboardExamThumbnail(imagePath: imagePath),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }
}

class _DashboardExamThumbnail extends StatelessWidget {
  final String? imagePath;

  const _DashboardExamThumbnail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final path = imagePath?.trim() ?? '';

    if (path.isEmpty) return const SizedBox.shrink();

    final bool isAsset = path.startsWith('assets/');
    final ImageProvider<Object> previewImage = isAsset
        ? AssetImage(path) as ImageProvider<Object>
        : FileImage(File(path)) as ImageProvider<Object>;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullscreenImageView(
              image: previewImage,
              title: 'X-ray image',
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          width: 64,
          padding: const EdgeInsets.all(5),
          color: scheme.surfaceVariant.withOpacity(0.7),
          child: isAsset
              ? Image.asset(path, fit: BoxFit.contain)
              : Image.file(File(path), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
