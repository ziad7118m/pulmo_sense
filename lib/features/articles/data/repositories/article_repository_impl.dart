import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/articles/data/datasources/article_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/articles/data/dtos/article_reaction_status_dto.dart';
import 'package:lung_diagnosis_app/features/articles/data/dtos/article_upsert_request_dto.dart';
import 'package:lung_diagnosis_app/features/articles/data/mappers/article_mapper.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article_draft.dart';
import 'package:lung_diagnosis_app/features/articles/domain/repositories/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _remote;
  final ValueNotifier<int> _changes = ValueNotifier<int>(0);

  ArticleRepositoryImpl({required ArticleRemoteDataSource remote})
    : _remote = remote;

  @override
  ValueListenable<int> get changes => _changes;

  void _notifyChanged() {
    _changes.value = _changes.value + 1;
  }

  @override
  Future<List<Article>> all() async {
    return ArticleMapper.fromDtoList(await _remote.all());
  }

  @override
  Future<List<Article>> allVisible() async {
    return ArticleMapper.fromDtoList(await _remote.allVisible());
  }

  @override
  Future<List<Article>> mine() async {
    return ArticleMapper.fromDtoList(await _remote.mine());
  }

  @override
  Future<List<Article>> mineVisible() async {
    final items = ArticleMapper.fromDtoList(await _remote.mine());
    return items
        .where((article) => !article.isHiddenByAdmin)
        .toList(growable: false);
  }

  @override
  Future<List<Article>> byAuthor(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return const <Article>[];
    return ArticleMapper.fromDtoList(await _remote.byAuthor(normalized));
  }

  @override
  Future<Article?> getById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;

    final dto = await _remote.getById(normalized);
    return dto == null ? null : ArticleMapper.fromDto(dto);
  }

  @override
  Future<Article> createFromDraft(ArticleDraft draft) async {
    if (!draft.isValid) {
      throw ArgumentError('Article draft is incomplete.');
    }

    final dto = await _remote.upsert(ArticleUpsertRequestDto.fromDraft(draft));
    if (dto == null) {
      throw StateError('Remote article create returned no payload.');
    }

    _notifyChanged();
    return ArticleMapper.fromDto(dto);
  }

  @override
  Future<Article> upsert(Article article) async {
    final dto = await _remote.upsert(ArticleUpsertRequestDto.fromDomain(article));
    _notifyChanged();
    return dto == null ? article : ArticleMapper.fromDto(dto);
  }

  @override
  Future<void> delete(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return;
    await _remote.delete(normalized);
    _notifyChanged();
  }

  @override
  Future<void> setAdminHidden(String articleId, bool hidden) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return;
    await _remote.setAdminHidden(normalized, hidden);
    _notifyChanged();
  }

  @override
  Future<int> favouriteCount(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return 0;

    final state = await _remote.reactionStatus(normalized);
    return state?.favouriteCount ?? 0;
  }

  @override
  Future<bool> isFavourite(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return false;

    final state = await _remote.reactionStatus(normalized);
    return state?.isFavourite ?? false;
  }

  @override
  Future<void> toggleFavourite(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return;

    final ArticleReactionStatusDto? state = await _remote.toggleFavourite(normalized);
    if (state == null) {
      throw StateError('Remote article favourite toggle returned no state.');
    }
    _notifyChanged();
  }

  @override
  Future<List<Article>> favourites() async {
    return ArticleMapper.fromDtoList(await _remote.favourites());
  }

  @override
  Future<bool> isSaved(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return false;

    final state = await _remote.reactionStatus(normalized);
    return state?.isSaved ?? false;
  }

  @override
  Future<void> toggleSaved(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return;

    final ArticleReactionStatusDto? state = await _remote.toggleSaved(normalized);
    if (state == null) {
      throw StateError('Remote article saved toggle returned no state.');
    }
    _notifyChanged();
  }

  @override
  Future<List<Article>> saved() async {
    return ArticleMapper.fromDtoList(await _remote.saved());
  }
}
