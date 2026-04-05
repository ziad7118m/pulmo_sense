import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/fullscreen_image_view.dart';

class ArticleImagesPickerCard extends StatelessWidget {
  final List<File> images;
  final int maxImages;
  final VoidCallback onAddImages;
  final ValueChanged<int> onRemoveImageAt;

  const ArticleImagesPickerCard({
    super.key,
    required this.images,
    required this.maxImages,
    required this.onAddImages,
    required this.onRemoveImageAt,
  });

  void _openPreview(BuildContext context, File file, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenImageView(
          image: FileImage(file),
          title: 'Article image ${index + 1}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (images.isEmpty) {
      return InkWell(
        onTap: onAddImages,
        borderRadius: BorderRadius.circular(24),
        child: Container(
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add article images',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Preview up to $maxImages images before posting.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      );
    }

    final File coverImage = images.first;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image preview',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${images.length}/$maxImages selected • Tap any image to preview',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: images.length >= maxImages ? null : onAddImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: const Text('Add more'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _openPreview(context, coverImage, 0),
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      coverImage,
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.58),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.open_in_full_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Preview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(images.length, (i) {
                final file = images[i];
                final bool isPrimary = i == 0;

                return Stack(
                  children: [
                    InkWell(
                      onTap: () => _openPreview(context, file, i),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPrimary
                                ? scheme.primary.withOpacity(0.30)
                                : scheme.outlineVariant,
                            width: isPrimary ? 1.4 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            file,
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (isPrimary)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Cover',
                            style: TextStyle(
                              color: scheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () => onRemoveImageAt(i),
                        borderRadius: BorderRadius.circular(99),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.62),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
