import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/models/article_section_view_data.dart';

class ArticleSectionController {
  final ArticleController _articles;
  final int limit;

  const ArticleSectionController(
    this._articles, {
    this.limit = 2,
  });

  ValueListenable<int> get changes => _articles.changes;

  Future<ArticleSectionViewData> load() async {
    final items = await _articles.allVisible();
    return ArticleSectionViewData(
      items: items.take(limit).toList(growable: false),
    );
  }
}
