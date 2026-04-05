import 'package:lung_diagnosis_app/features/articles/data/dtos/article_dto.dart';
import 'package:lung_diagnosis_app/features/articles/data/local_article.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article_draft.dart';

class ArticleMapper {
  const ArticleMapper._();

  static Article toDomain(LocalArticle local) {
    return Article(
      id: local.id,
      doctorName: local.doctorName,
      title: local.title,
      content: local.content,
      doctorImage: local.doctorImage,
      articleImages: List<String>.from(local.articleImages),
      articleImage: local.articleImage,
      createdAt: local.createdAt,
      createdByUserId: local.createdByUserId,
      isHiddenByAdmin: local.isHiddenByAdmin,
    );
  }

  static Article fromDto(ArticleDto dto) {
    return Article(
      id: dto.id,
      doctorName: dto.doctorName,
      title: dto.title,
      content: dto.content,
      doctorImage: dto.doctorImage.trim().isEmpty ? null : dto.doctorImage,
      articleImages: List<String>.from(dto.articleImages),
      articleImage: dto.articleImage.trim().isEmpty ? null : dto.articleImage,
      createdAt: dto.createdAt,
      createdByUserId: dto.createdByUserId,
      isHiddenByAdmin: dto.isHiddenByAdmin,
    );
  }

  static Article fromDraft(
    ArticleDraft draft, {
    required String id,
    required DateTime createdAt,
    bool isHiddenByAdmin = false,
  }) {
    final images = draft.imagePaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);

    return Article(
      id: id.trim(),
      doctorName: draft.authorName.trim(),
      title: draft.title.trim(),
      content: draft.content.trim(),
      doctorImage: _normalize(draft.authorAvatarPath),
      articleImages: images,
      articleImage: images.isEmpty ? null : images.first,
      createdAt: createdAt,
      createdByUserId: draft.authorUserId.trim(),
      isHiddenByAdmin: isHiddenByAdmin,
    );
  }

  static LocalArticle toLocal(Article article) {
    return LocalArticle(
      id: article.id,
      doctorName: article.doctorName,
      title: article.title,
      content: article.content,
      doctorImage: article.doctorImage,
      articleImages: List<String>.from(article.articleImages),
      articleImage: article.articleImage,
      createdAt: article.createdAt,
      createdByUserId: article.createdByUserId,
      isHiddenByAdmin: article.isHiddenByAdmin,
    );
  }

  static List<Article> toDomainList(Iterable<LocalArticle> locals) {
    return locals.map(toDomain).toList(growable: false);
  }

  static List<Article> fromDtoList(Iterable<ArticleDto> dtos) {
    return dtos.map(fromDto).toList(growable: false);
  }

  static String? _normalize(String? value) {
    final normalized = (value ?? '').trim();
    return normalized.isEmpty ? null : normalized;
  }
}
