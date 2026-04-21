import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_image.dart';
import 'package:lung_diagnosis_app/core/widgets/fullscreen_image_view.dart';

class DiagnosisDetailsXrayHeader extends StatelessWidget {
  final String type;
  final String? imagePath;

  const DiagnosisDetailsXrayHeader({
    super.key,
    required this.type,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    if (type != 'xray' || imagePath == null || imagePath!.isEmpty) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final path = imagePath!;
    final isAsset = path.startsWith('assets/');
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    final ImageProvider<Object> previewImage = isAsset
        ? AssetImage(path) as ImageProvider<Object>
        : isNetwork
            ? NetworkImage(path) as ImageProvider<Object>
            : FileImage(File(path)) as ImageProvider<Object>;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
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
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: scheme.surface,
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: scheme.primary.withOpacity(0.10),
                      ),
                      child: Icon(
                        Icons.image_search_rounded,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chest X-ray preview',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to open and zoom the image in full screen.',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_full_rounded, size: 16, color: scheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Preview',
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 260,
                    color: scheme.surfaceVariant.withOpacity(0.45),
                    child: isAsset
                        ? Image.asset(path, fit: BoxFit.contain)
                        : isNetwork
                            ? AppImage(
                                path: path,
                                fit: BoxFit.contain,
                                loadingLabel: 'Loading X-ray...',
                                errorLabel: 'X-ray unavailable',
                              )
                            : Image.file(File(path), fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
