import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article_draft.dart';

class ArticleUpsertRequestDto {
  final String id;
  final String doctorName;
  final String title;
  final String content;
  final String doctorImage;
  final List<String> articleImages;
  final String articleImage;
  final DateTime createdAt;
  final String createdByUserId;
  final bool isHiddenByAdmin;

  const ArticleUpsertRequestDto({
    required this.id,
    required this.doctorName,
    required this.title,
    required this.content,
    required this.doctorImage,
    required this.articleImages,
    required this.articleImage,
    required this.createdAt,
    required this.createdByUserId,
    required this.isHiddenByAdmin,
  });

  factory ArticleUpsertRequestDto.fromDomain(Article article) {
    return ArticleUpsertRequestDto(
      id: article.id,
      doctorName: article.doctorName,
      title: article.title,
      content: article.content,
      doctorImage: article.doctorImage ?? '',
      articleImages: List<String>.from(article.articleImages),
      articleImage: article.articleImage ?? '',
      createdAt: article.createdAt,
      createdByUserId: article.createdByUserId,
      isHiddenByAdmin: article.isHiddenByAdmin,
    );
  }

  factory ArticleUpsertRequestDto.fromDraft(ArticleDraft draft) {
    final articleImages = draft.imagePaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);

    return ArticleUpsertRequestDto(
      id: '',
      doctorName: draft.authorName.trim(),
      title: draft.title.trim(),
      content: draft.content.trim(),
      doctorImage: (draft.authorAvatarPath ?? '').trim(),
      articleImages: articleImages,
      articleImage: articleImages.isEmpty ? '' : articleImages.first,
      createdAt: DateTime.now(),
      createdByUserId: draft.authorUserId.trim(),
      isHiddenByAdmin: false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id.trim().isNotEmpty) 'id': id,
      'doctorName': doctorName,
      'title': title,
      'content': content,
      'doctorImage': doctorImage,
      'articleImages': articleImages,
      if (articleImage.trim().isNotEmpty) 'articleImage': articleImage,
      'createdAt': createdAt.toIso8601String(),
      'createdByUserId': createdByUserId,
      'isHiddenByAdmin': isHiddenByAdmin,
    };
  }
}
