import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_image.dart';
import 'package:lung_diagnosis_app/core/widgets/fullscreen_image_view.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/helpers/diagnosis_history_item_meta_resolver.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DiagnosisHistoryItemCard extends StatelessWidget {
  final DiagnosisKind kind;
  final bool isDoctor;
  final DiagnosisItem item;
  final VoidCallback onTap;

  const DiagnosisHistoryItemCard({
    super.key,
    required this.kind,
    required this.isDoctor,
    required this.item,
    required this.onTap,
  });

  Widget _thumb(BuildContext context) {
    if (kind != DiagnosisKind.xray) return const SizedBox.shrink();
    if (item.imagePath == null || item.imagePath!.isEmpty) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final path = item.imagePath!;
    final isAsset = path.startsWith('assets/');
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    final ImageProvider<Object> previewImage = isAsset
        ? AssetImage(path) as ImageProvider<Object>
        : isNetwork
            ? NetworkImage(path) as ImageProvider<Object>
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
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(6),
          color: scheme.surfaceVariant.withOpacity(0.7),
          child: isAsset
              ? Image.asset(path, fit: BoxFit.contain)
              : isNetwork
                  ? AppImage(
                      path: path,
                      fit: BoxFit.contain,
                      loadingLabel: 'Loading X-ray...',
                      errorLabel: 'Preview unavailable',
                    )
                  : Image.file(File(path), fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondaryLine = DiagnosisHistoryItemMetaResolver.secondaryLine(
      kind: kind,
      isDoctor: isDoctor,
      item: item,
    );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _thumb(context),
              if (kind == DiagnosisKind.xray && item.imagePath != null)
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.diagnosis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.dateTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (secondaryLine != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          secondaryLine,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
