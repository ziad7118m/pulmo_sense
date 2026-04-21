import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/add_article_author_card.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_images_picker_card.dart';

class ArticleComposeForm extends StatelessWidget {
  final String doctorName;
  final String avatarPath;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final List<File> images;
  final int maxImages;
  final bool isEditing;
  final int existingImageCount;
  final VoidCallback onAddImages;
  final ValueChanged<int> onRemoveImageAt;

  const ArticleComposeForm({
    super.key,
    required this.doctorName,
    required this.avatarPath,
    required this.titleController,
    required this.contentController,
    required this.images,
    required this.maxImages,
    required this.isEditing,
    required this.existingImageCount,
    required this.onAddImages,
    required this.onRemoveImageAt,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddArticleAuthorCard(
          doctorName: doctorName,
          avatarPath: avatarPath,
          onAddImages: onAddImages,
        ),
        const SizedBox(height: 18),
        if (isEditing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withOpacity(0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              existingImageCount > 0
                  ? 'Editing article. Keep images empty to preserve current backend images, or add new ones to replace them.'
                  : 'Editing article. Update the title or content, and optionally add new images.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        if (isEditing) const SizedBox(height: 18),
        Text(
          'Article details',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          labelText: AppStrings.title,
          controller: titleController,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          labelText: AppStrings.addArticleBox,
          controller: contentController,
          maxLines: 9,
        ),
        const SizedBox(height: 18),
        Text(
          isEditing ? 'New image preview' : 'Image preview',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ArticleImagesPickerCard(
          images: images,
          maxImages: maxImages,
          onAddImages: onAddImages,
          onRemoveImageAt: onRemoveImageAt,
        ),
      ],
    );
  }
}
