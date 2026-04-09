import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/articles/data/dtos/article_dto.dart';
import 'package:lung_diagnosis_app/features/articles/data/dtos/article_reaction_status_dto.dart';
import 'package:lung_diagnosis_app/features/articles/data/dtos/article_upsert_request_dto.dart';

class ArticleRemoteDataSource {
  final ApiClient _apiClient;

  ArticleRemoteDataSource(this._apiClient);

  ApiClient get apiClient => _apiClient;

  String _articlePath(String id) => '${Endpoints.articles}/${id.trim()}';

  Future<List<ArticleDto>> all() {
    return _getArticleList(Endpoints.articles);
  }

  Future<List<ArticleDto>> allVisible() async {
    final items = await all();
    return items.where((article) => !article.isHiddenByAdmin).toList(growable: false);
  }

  Future<List<ArticleDto>> mine() {
    return all();
  }

  Future<List<ArticleDto>> byAuthor(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return const <ArticleDto>[];
    final items = await all();
    return items.where((article) => article.createdByUserId == normalized).toList(growable: false);
  }

  Future<List<ArticleDto>> favourites() {
    return _getArticleList(Endpoints.articleFavourites);
  }

  Future<List<ArticleDto>> saved() {
    return favourites();
  }

  Future<ArticleDto?> getById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;

    final Result<ArticleDto> result = await _apiClient.get<ArticleDto>(
      _articlePath(normalized),
      decode: (dynamic data) => ArticleDto.fromJson(_extractArticleMap(data)),
    );

    if (result is Success<ArticleDto>) {
      return result.value;
    }

    final allItems = await all();
    for (final article in allItems) {
      if (article.id == normalized) return article;
    }
    return null;
  }

  Future<ArticleDto?> upsert(ArticleUpsertRequestDto request) async {
    final normalizedId = request.id.trim();
    final path = normalizedId.isEmpty ? Endpoints.articles : _articlePath(normalizedId);
    final formData = await _buildPostFormData(request);

    try {
      final response = normalizedId.isEmpty
          ? await _apiClient.raw.post<dynamic>(path, data: formData)
          : await _apiClient.raw.put<dynamic>(path, data: formData);
      return ArticleDto.fromJson(_extractArticleMap(response.data));
    } catch (_) {
      throw StateError('Failed to persist remote article.');
    }
  }

  Future<void> delete(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return;
    await _apiClient.delete<dynamic>(_articlePath(normalized));
  }

  Future<ArticleDto?> setAdminHidden(String articleId, bool hidden) async {
    throw StateError('Remote article moderation is not available on this backend yet.');
  }

  Future<ArticleReactionStatusDto?> reactionStatus(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return null;

    final favorites = await favourites();
    final isFavourite = favorites.any((article) => article.id == normalized);
    return ArticleReactionStatusDto(
      isFavourite: isFavourite,
      isSaved: isFavourite,
      favouriteCount: null,
    );
  }

  Future<ArticleReactionStatusDto?> toggleFavourite(String articleId) async {
    final postId = int.tryParse(articleId.trim());
    if (postId == null) {
      throw StateError('Invalid article id for favorites endpoint.');
    }

    final current = await reactionStatus(articleId);
    final alreadyFavourite = current?.isFavourite ?? false;

    final result = alreadyFavourite
        ? await _apiClient.delete<dynamic>(
            Endpoints.articleFavourites,
            body: <String, dynamic>{'postId': postId},
          )
        : await _apiClient.post<dynamic>(
            Endpoints.articleFavourites,
            body: <String, dynamic>{'postId': postId},
          );

    if (result is FailureResult<dynamic>) {
      throw StateError('Failed to toggle remote article favourite state.');
    }

    return ArticleReactionStatusDto(isFavourite: !alreadyFavourite, isSaved: !alreadyFavourite);
  }

  Future<ArticleReactionStatusDto?> toggleSaved(String articleId) {
    return toggleFavourite(articleId);
  }

  Future<List<ArticleDto>> _getArticleList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final Result<List<ArticleDto>> result = await _apiClient.get<List<ArticleDto>>(
      path,
      query: query,
      decode: (dynamic data) {
        final list = _extractArticleList(data);
        return list.map(ArticleDto.fromJson).toList(growable: false);
      },
    );

    if (result is Success<List<ArticleDto>>) {
      return result.value;
    }
    throw StateError('Failed to fetch remote articles.');
  }

  Future<FormData> _buildPostFormData(ArticleUpsertRequestDto request) async {
    final map = <String, dynamic>{
      'Title': request.title,
      'Description': request.content,
    };

    final files = <MultipartFile>[];
    for (final path in request.articleImages) {
      final normalized = path.trim();
      if (normalized.isEmpty) continue;
      final file = File(normalized);
      if (!file.existsSync()) continue;
      files.add(await MultipartFile.fromFile(normalized, filename: file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : 'image.jpg'));
    }

    if (files.isNotEmpty) {
      map['Images'] = files;
    }

    return FormData.fromMap(map);
  }

  Map<String, dynamic> _extractArticleMap(dynamic data) {
    final root = _extractMap(data);
    final nestedData = _asMap(root['data']);
    final nestedArticle = _mapValue(nestedData, 'article') ??
        _mapValue(nestedData, 'item') ??
        _mapValue(root, 'article') ??
        _mapValue(root, 'item') ??
        _mapValue(root, 'result');
    return nestedArticle ?? nestedData ?? root;
  }

  List<Map<String, dynamic>> _extractArticleList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    final root = _extractMap(data);
    final nestedData = root['data'];
    final nested = nestedData is List
        ? nestedData
        : root['items'] ?? root['articles'] ?? root['results'];

    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    final map = _asMap(data);
    return map ?? <String, dynamic>{};
  }

  Map<String, dynamic>? _mapValue(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    return _asMap(map[key]);
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
