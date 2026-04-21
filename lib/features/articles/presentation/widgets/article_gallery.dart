import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_image.dart';
import 'package:lung_diagnosis_app/core/widgets/fullscreen_image_view.dart';

class ArticleGallery extends StatelessWidget {
  final List<String> images;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;

  const ArticleGallery({
    super.key,
    required this.images,
    required this.activeIndex,
    required this.onPageChanged,
  });

  ImageProvider<Object>? _providerFor(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    if (trimmed.startsWith('assets/')) {
      return AssetImage(trimmed);
    }
    final file = File(trimmed);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  void _openImage(BuildContext context, String path, int index) {
    final provider = _providerFor(path);
    if (provider == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenImageView(
          image: provider,
          title: 'Article image ${index + 1}',
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme scheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        height: 240,
        color: scheme.primaryContainer,
        child: Icon(Icons.image_outlined, color: scheme.primary, size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (images.isEmpty) {
      return _buildPlaceholder(scheme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 260,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, i) {
                      final path = images[i];
                      final provider = _providerFor(path);

                      if (provider == null) {
                        return _buildPlaceholder(scheme);
                      }

                      return Material(
                        color: scheme.surfaceVariant,
                        child: InkWell(
                          onTap: () => _openImage(context, path, i),
                          child: AppImage(
                            path: path,
                            fit: BoxFit.cover,
                            errorLabel: '',
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${activeIndex + 1}/${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_in_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Tap to preview',
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
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final provider = _providerFor(images[i]);
                final bool active = i == activeIndex;

                return GestureDetector(
                  onTap: () => _openImage(context, images[i], i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 76,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: active ? scheme.primary : scheme.outlineVariant,
                        width: active ? 1.8 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: provider == null
                          ? Container(
                              color: scheme.primaryContainer,
                              child: Icon(
                                Icons.image_outlined,
                                color: scheme.primary,
                              ),
                            )
                          : AppImage(
                              path: images[i],
                              fit: BoxFit.cover,
                              errorLabel: '',
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
