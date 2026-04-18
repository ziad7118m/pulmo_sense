import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/models/article_collection_view_data.dart';

enum ArticleCollectionKind { allVisible, favourites, mineVisible, saved }

class ArticleCollectionController {
  final ArticleController _articles;
  final ArticleCollectionKind kind;

  const ArticleCollectionController(this._articles, {required this.kind});

  ValueListenable<int> get changes => _articles.changes;

  Future<List<Article>> load() {
    switch (kind) {
      case ArticleCollectionKind.allVisible:
        return _articles.allVisible();
      case ArticleCollectionKind.favourites:
        return _articles.favourites();
      case ArticleCollectionKind.mineVisible:
        return _articles.mineVisible();
      case ArticleCollectionKind.saved:
        return _articles.favourites();
    }
  }

  ArticleCollectionViewData get viewData {
    switch (kind) {
      case ArticleCollectionKind.allVisible:
        return const ArticleCollectionViewData(
          title: AppStrings.medicalArticles,
          emptyIcon: Icons.article_outlined,
          emptyTitle: 'No articles available',
          emptyMessage: 'Articles will appear here once they are added.',
          useResponsiveCollection: true,
        );
      case ArticleCollectionKind.favourites:
        return const ArticleCollectionViewData(
          title: AppStrings.favouriteArticles,
          emptyIcon: Icons.favorite_border_rounded,
          emptyTitle: AppStrings.noFavoriteArticles,
          emptyMessage: 'Save articles you like so you can find them quickly here.',
          emptyActionText: 'Browse articles',
        );
      case ArticleCollectionKind.mineVisible:
        return const ArticleCollectionViewData(
          title: AppStrings.myArticles,
          emptyIcon: Icons.article_outlined,
          emptyTitle: 'No articles yet',
          emptyMessage: 'Create your first medical article to see it here.',
          emptyActionText: AppStrings.addArticle,
          showOwnerDelete: true,
          showHiddenBadge: true,
        );
      case ArticleCollectionKind.saved:
        return const ArticleCollectionViewData(
          title: 'Saved Articles',
          emptyIcon: Icons.bookmark_outline_rounded,
          emptyTitle: 'No saved articles',
          emptyMessage: 'Save articles to read them later and find them quickly here.',
          emptyActionText: 'Browse articles',
        );
    }
  }
}
