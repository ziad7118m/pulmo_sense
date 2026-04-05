import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';

class ArticleSectionViewData {
  final List<Article> items;

  const ArticleSectionViewData({
    required this.items,
  });

  bool get isEmpty => items.isEmpty;
}
