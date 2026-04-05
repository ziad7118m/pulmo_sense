import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/core/utils/id_generator.dart';
import 'package:lung_diagnosis_app/features/articles/data/article_store.dart';
import 'package:lung_diagnosis_app/features/articles/data/mappers/article_mapper.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article_draft.dart';
import 'package:lung_diagnosis_app/features/articles/domain/repositories/article_repository.dart';

class LocalArticleRepository implements ArticleRepository {
  final ArticleStore _store;

  LocalArticleRepository(this._store);

  @override
  ValueListenable<int> get changes => _store.changes;

  @override
  Future<List<Article>> all() async => ArticleMapper.toDomainList(await _store.all());

  @override
  Future<List<Article>> allVisible() async =>
      ArticleMapper.toDomainList(await _store.allVisible());

  @override
  Future<List<Article>> mine() async => ArticleMapper.toDomainList(await _store.mine());

  @override
  Future<List<Article>> mineVisible() async =>
      ArticleMapper.toDomainList(await _store.mineVisible());

  @override
  Future<List<Article>> byAuthor(String userId) async =>
      ArticleMapper.toDomainList(await _store.byAuthor(userId));

  @override
  Future<Article?> getById(String id) async {
    final article = await _store.getById(id);
    return article == null ? null : ArticleMapper.toDomain(article);
  }

  @override
  Future<Article> createFromDraft(ArticleDraft draft) async {
    if (!draft.isValid) {
      throw ArgumentError('Article draft is incomplete.');
    }

    final article = ArticleMapper.fromDraft(
      draft,
      id: IdGenerator.next(prefix: 'article'),
      createdAt: DateTime.now(),
    );

    await _store.upsert(ArticleMapper.toLocal(article));
    return article;
  }

  @override
  Future<Article> upsert(Article article) async {
    await _store.upsert(ArticleMapper.toLocal(article));
    return article;
  }

  @override
  Future<void> delete(String id) => _store.delete(id);

  @override
  Future<void> setAdminHidden(String articleId, bool hidden) =>
      _store.setAdminHidden(articleId, hidden);

  @override
  Future<int> favouriteCount(String articleId) => _store.favouriteCount(articleId);

  @override
  Future<bool> isFavourite(String articleId) => _store.isFavourite(articleId);

  @override
  Future<void> toggleFavourite(String articleId) => _store.toggleFavourite(articleId);

  @override
  Future<List<Article>> favourites() async =>
      ArticleMapper.toDomainList(await _store.favourites());

  @override
  Future<bool> isSaved(String articleId) => _store.isSaved(articleId);

  @override
  Future<void> toggleSaved(String articleId) => _store.toggleSaved(articleId);

  @override
  Future<List<Article>> saved() async => ArticleMapper.toDomainList(await _store.saved());
}
