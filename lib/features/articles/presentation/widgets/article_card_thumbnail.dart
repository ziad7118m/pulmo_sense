import 'dart:io';

import 'package:flutter/material.dart';

class ArticleCardThumbnail extends StatelessWidget {
  final String articleImage;

  const ArticleCardThumbnail({
    super.key,
    required this.articleImage,
  });

  bool _hasFile(String path) {
    return path.trim().isNotEmpty &&
        (path.startsWith('assets/') || File(path).existsSync());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasArticleImage = _hasFile(articleImage);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: hasArticleImage
          ? (articleImage.startsWith('assets/')
              ? Image.asset(
                  articleImage,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(articleImage),
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                ))
          : Container(
              width: 84,
              height: 84,
              color: scheme.primaryContainer,
              child: Icon(
                Icons.image_outlined,
                color: scheme.primary,
              ),
            ),
    );
  }
}
