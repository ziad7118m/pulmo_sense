import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article_draft.dart';

abstract class ArticleRepository {
  ValueListenable<int> get changes;

  Future<List<Article>> all();
  Future<List<Article>> allVisible();
  Future<List<Article>> mine();
  Future<List<Article>> mineVisible();
  Future<List<Article>> byAuthor(String userId);
  Future<Article?> getById(String id);
  Future<Article> createFromDraft(ArticleDraft draft);
  Future<Article> upsert(Article article);
  Future<void> delete(String id);
  Future<void> setAdminHidden(String articleId, bool hidden);

  Future<int> favouriteCount(String articleId);
  Future<bool> isFavourite(String articleId);
  Future<void> toggleFavourite(String articleId);
  Future<List<Article>> favourites();

  Future<bool> isSaved(String articleId);
  Future<void> toggleSaved(String articleId);
  Future<List<Article>> saved();
}
