import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

Future<void> showArticleImageSourceSheet({
  required BuildContext context,
  required int maxImages,
  required Future<void> Function() onPickFromGallery,
  required Future<void> Function() onPickFromCamera,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) {
      final scheme = Theme.of(context).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('${AppStrings.gallery} (max $maxImages)'),
                onTap: () async {
                  Navigator.pop(context);
                  await onPickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(AppStrings.camera),
                onTap: () async {
                  Navigator.pop(context);
                  await onPickFromCamera();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
