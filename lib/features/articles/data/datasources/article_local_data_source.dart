import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/articles/data/article_store.dart';
import 'package:lung_diagnosis_app/features/articles/data/local_article.dart';

class ArticleLocalDataSource {
  final ArticleStore _store;

  ArticleLocalDataSource(this._store);

  ValueListenable<int> get changes => _store.changes;

  Future<List<LocalArticle>> all() => _store.all();
  Future<List<LocalArticle>> allVisible() => _store.allVisible();
  Future<List<LocalArticle>> mine() => _store.mine();
  Future<List<LocalArticle>> mineVisible() => _store.mineVisible();
  Future<List<LocalArticle>> byAuthor(String userId) => _store.byAuthor(userId);
  Future<LocalArticle?> getById(String id) => _store.getById(id);
  Future<void> upsert(LocalArticle article) => _store.upsert(article);
  Future<void> delete(String id) => _store.delete(id);
  Future<void> setAdminHidden(String articleId, bool hidden) =>
      _store.setAdminHidden(articleId, hidden);
  Future<int> favouriteCount(String articleId) => _store.favouriteCount(articleId);
  Future<bool> isFavourite(String articleId) => _store.isFavourite(articleId);
  Future<void> toggleFavourite(String articleId) => _store.toggleFavourite(articleId);
  Future<void> setFavourite(String articleId, bool isFavourite) =>
      _store.setFavourite(articleId, isFavourite);
  Future<void> replaceFavourites(Iterable<String> articleIds) =>
      _store.replaceFavourites(articleIds);
  Future<List<LocalArticle>> favourites() => _store.favourites();
  Future<bool> isSaved(String articleId) => _store.isSaved(articleId);
  Future<void> toggleSaved(String articleId) => _store.toggleSaved(articleId);
  Future<void> setSaved(String articleId, bool isSaved) =>
      _store.setSaved(articleId, isSaved);
  Future<void> replaceSaved(Iterable<String> articleIds) => _store.replaceSaved(articleIds);
  Future<List<LocalArticle>> saved() => _store.saved();
}
