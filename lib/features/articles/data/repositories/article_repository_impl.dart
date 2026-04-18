import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/articles/data/datasources/article_local_data_source.dart';
import 'package:lung_diagnosis_app/features/articles/data/datasources/article_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/articles/data/dtos/article_reaction_status_dto.dart';
import 'package:lung_diagnosis_app/features/articles/data/dtos/article_upsert_request_dto.dart';
import 'package:lung_diagnosis_app/features/articles/data/mappers/article_mapper.dart';
import 'package:lung_diagnosis_app/core/utils/id_generator.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article_draft.dart';
import 'package:lung_diagnosis_app/features/articles/domain/repositories/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleLocalDataSource _local;
  final ArticleRemoteDataSource? _remote;

  ArticleRepositoryImpl({
    required ArticleLocalDataSource local,
    ArticleRemoteDataSource? remote,
  })  : _local = local,
        _remote = remote;

  @override
  ValueListenable<int> get changes => _local.changes;

  @override
  Future<List<Article>> all() async {
    final remote = _remote;
    if (remote != null) {
      try {
        final articles = ArticleMapper.fromDtoList(await remote.all());
        await _cacheArticles(articles);
        return articles;
      } catch (_) {}
    }
    return ArticleMapper.toDomainList(await _local.all());
  }

  @override
  Future<List<Article>> allVisible() async {
    final remote = _remote;
    if (remote != null) {
      try {
        final articles = ArticleMapper.fromDtoList(await remote.allVisible());
        await _cacheArticles(articles);
        return articles;
      } catch (_) {}
    }
    return ArticleMapper.toDomainList(await _local.allVisible());
  }

  @override
  Future<List<Article>> mine() async {
    final remote = _remote;
    if (remote != null) {
      try {
        final articles = ArticleMapper.fromDtoList(await remote.mine());
        await _cacheArticles(articles);
        return articles;
      } catch (_) {}
    }
    return ArticleMapper.toDomainList(await _local.mine());
  }

  @override
  Future<List<Article>> mineVisible() async {
    final remote = _remote;
    if (remote != null) {
      try {
        final articles = ArticleMapper.fromDtoList(await remote.mine());
        await _cacheArticles(articles);
        return articles;
      } catch (_) {}
    }
    return ArticleMapper.toDomainList(await _local.mineVisible());
  }

  @override
  Future<List<Article>> byAuthor(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return const <Article>[];

    final remote = _remote;
    if (remote != null) {
      try {
        final articles = ArticleMapper.fromDtoList(await remote.byAuthor(normalized));
        await _cacheArticles(articles);
        return articles;
      } catch (_) {}
    }
    return ArticleMapper.toDomainList(await _local.byAuthor(normalized));
  }

  @override
  Future<Article?> getById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;

    final remote = _remote;
    if (remote != null) {
      try {
        final dto = await remote.getById(normalized);
        if (dto != null) {
          final article = ArticleMapper.fromDto(dto);
          await _cacheArticle(article);
          return article;
        }
      } catch (_) {}
    }

    final local = await _local.getById(normalized);
    return local == null ? null : ArticleMapper.toDomain(local);
  }

  @override
  Future<Article> createFromDraft(ArticleDraft draft) async {
    if (!draft.isValid) {
      throw ArgumentError('Article draft is incomplete.');
    }

    final remote = _remote;
    if (remote != null) {
      try {
        final dto = await remote.upsert(ArticleUpsertRequestDto.fromDraft(draft));
        if (dto != null) {
          final resolved = ArticleMapper.fromDto(dto);
          await _cacheArticle(resolved);
          return resolved;
        }
      } catch (_) {}
    }

    final localArticle = ArticleMapper.fromDraft(
      draft,
      id: IdGenerator.next(prefix: 'article'),
      createdAt: DateTime.now(),
    );
    await _cacheArticle(localArticle);
    return localArticle;
  }

  @override
  Future<Article> upsert(Article article) async {
    final remote = _remote;
    if (remote != null) {
      try {
        final dto = await remote.upsert(ArticleUpsertRequestDto.fromDomain(article));
        final resolved = dto == null ? article : ArticleMapper.fromDto(dto);
        await _cacheArticle(resolved);
        return resolved;
      } catch (_) {}
    }

    await _cacheArticle(article);
    return article;
  }

  @override
  Future<void> delete(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return;

    final remote = _remote;
    if (remote != null) {
      try {
        await remote.delete(normalized);
      } catch (_) {}
    }
    await _local.delete(normalized);
  }

  @override
  Future<void> setAdminHidden(String articleId, bool hidden) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return;

    final remote = _remote;
    if (remote != null) {
      try {
        final dto = await remote.setAdminHidden(normalized, hidden);
        if (dto != null) {
          await _cacheArticle(ArticleMapper.fromDto(dto));
          return;
        }
      } catch (_) {}
    }

    await _local.setAdminHidden(normalized, hidden);
  }

  @override
  Future<int> favouriteCount(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return 0;

    final remote = _remote;
    if (remote != null) {
      try {
        final state = await remote.reactionStatus(normalized);
        final count = state?.favouriteCount;
        if (count != null) return count;
      } catch (_) {}
    }
    return _local.favouriteCount(normalized);
  }

  @override
  Future<bool> isFavourite(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return false;

    final remote = _remote;
    if (remote != null) {
      try {
        final state = await remote.reactionStatus(normalized);
        final value = state?.isFavourite;
        if (value != null) {
          await _local.setFavourite(normalized, value, notify: false);
          return value;
        }
      } catch (_) {}
    }
    return _local.isFavourite(normalized);
  }

  @override
  Future<void> toggleFavourite(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return;

    final remote = _remote;
    if (remote != null) {
      try {
        final ArticleReactionStatusDto? state = await remote.toggleFavourite(normalized);
        final resolved = state?.isFavourite;
        if (resolved != null) {
          await _local.setFavourite(normalized, resolved);
          return;
        }
      } catch (_) {}
    }
    await _local.toggleFavourite(normalized);
  }

  @override
  Future<List<Article>> favourites() async {
    final remote = _remote;
    if (remote != null) {
      try {
        final articles = ArticleMapper.fromDtoList(await remote.favourites());
        await _cacheArticles(articles);
        await _local.replaceFavourites(articles.map((article) => article.id), notify: false);
        return articles;
      } catch (_) {}
    }
    return ArticleMapper.toDomainList(await _local.favourites());
  }

  @override
  Future<bool> isSaved(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return false;

    final remote = _remote;
    if (remote != null) {
      try {
        final state = await remote.reactionStatus(normalized);
        final value = state?.isSaved;
        if (value != null) {
          await _local.setSaved(normalized, value, notify: false);
          return value;
        }
      } catch (_) {}
    }
    return _local.isSaved(normalized);
  }

  @override
  Future<void> toggleSaved(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return;

    final remote = _remote;
    if (remote != null) {
      try {
        final ArticleReactionStatusDto? state = await remote.toggleSaved(normalized);
        final resolved = state?.isSaved;
        if (resolved != null) {
          await _local.setSaved(normalized, resolved);
          return;
        }
      } catch (_) {}
    }
    await _local.toggleSaved(normalized);
  }

  @override
  Future<List<Article>> saved() async {
    final remote = _remote;
    if (remote != null) {
      try {
        final articles = ArticleMapper.fromDtoList(await remote.saved());
        await _cacheArticles(articles);
        await _local.replaceSaved(articles.map((article) => article.id), notify: false);
        return articles;
      } catch (_) {}
    }
    return ArticleMapper.toDomainList(await _local.saved());
  }

  Future<void> _cacheArticles(Iterable<Article> articles) async {
    for (final article in articles) {
      await _cacheArticle(article);
    }
  }

  Future<void> _cacheArticle(Article article) async {
    await _local.upsert(ArticleMapper.toLocal(article), notify: false);
  }
}
