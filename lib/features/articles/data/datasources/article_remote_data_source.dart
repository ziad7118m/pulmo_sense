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
  Set<String>? _cachedFavouriteIds;

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

  Future<List<ArticleDto>> mine() async {
    final items = await all();
    final identities = await _resolveCurrentIdentityNames();
    if (identities.isEmpty) return items;
    return items
        .where((article) => identities.contains(article.doctorName.trim().toLowerCase()))
        .toList(growable: false);
  }

  Future<List<ArticleDto>> byAuthor(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return const <ArticleDto>[];
    final items = await all();
    final direct = items.where((article) => article.createdByUserId == normalized).toList(growable: false);
    if (direct.isNotEmpty) return direct;
    return mine();
  }

  Future<List<ArticleDto>> favourites() async {
    final items = await _getFavouriteArticles();
    _cachedFavouriteIds = items
        .map((article) => article.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    return items;
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

      if (normalizedId.isEmpty) {
        return ArticleDto.fromJson(_extractArticleMap(response.data));
      }

      final updatedId = (_extractUpdatedPostId(response.data)?.toString() ?? normalizedId).trim();
      return await getById(updatedId);
    } catch (_) {
      throw StateError('Failed to persist remote article.');
    }
  }

  Future<void> delete(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return;
    await _apiClient.delete<dynamic>(_articlePath(normalized));
    _cachedFavouriteIds?.remove(normalized);
  }

  Future<ArticleDto?> setAdminHidden(String articleId, bool hidden) async {
    throw StateError('Remote article moderation is not available on this backend yet.');
  }

  Future<ArticleReactionStatusDto?> reactionStatus(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return null;

    final favoriteIds = await _getFavouriteIds();
    final isFavourite = favoriteIds.contains(normalized);
    return ArticleReactionStatusDto(
      isFavourite: isFavourite,
      isSaved: isFavourite,
      favouriteCount: null,
    );
  }

  Future<ArticleReactionStatusDto?> toggleFavourite(String articleId) async {
    final normalized = articleId.trim();
    final postId = int.tryParse(normalized);
    if (postId == null) {
      throw StateError('Invalid article id for favorites endpoint.');
    }

    final favoriteIds = await _getFavouriteIds();
    final alreadyFavourite = favoriteIds.contains(normalized);

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
      throw StateError(result.failure.message);
    }

    if (alreadyFavourite) {
      favoriteIds.remove(normalized);
    } else {
      favoriteIds.add(normalized);
    }
    _cachedFavouriteIds = favoriteIds;

    return ArticleReactionStatusDto(
      isFavourite: !alreadyFavourite,
      isSaved: !alreadyFavourite,
      favouriteCount: null,
    );
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

    if (result is FailureResult<List<ArticleDto>>) {
      throw StateError(result.failure.message);
    }
    throw StateError('Failed to fetch remote articles.');
  }

  Future<List<ArticleDto>> _getFavouriteArticles() async {
    try {
      final response = await _apiClient.raw.get<dynamic>(
        Endpoints.articleFavourites,
        options: Options(validateStatus: (status) => status != null && status >= 200 && status < 500),
      );

      if (response.statusCode == 404) {
        return const <ArticleDto>[];
      }

      final list = _extractArticleList(response.data);
      return list.map(ArticleDto.fromJson).toList(growable: false);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 404) {
        return const <ArticleDto>[];
      }
      throw StateError('Failed to fetch favorite articles.');
    }
  }

  Future<Set<String>> _getFavouriteIds() async {
    final cached = _cachedFavouriteIds;
    if (cached != null) {
      return Set<String>.from(cached);
    }

    final items = await _getFavouriteArticles();
    final ids = items
        .map((article) => article.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    _cachedFavouriteIds = ids;
    return ids;
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

  int? _extractUpdatedPostId(dynamic data) {
    if (data is int) return data;
    if (data is num) return data.toInt();
    if (data is String) return int.tryParse(data.trim());

    final map = _asMap(data);
    if (map == null) return null;

    final dynamic candidate = map['id'] ?? map['postId'] ?? map['result'] ?? map['data'];
    if (candidate is int) return candidate;
    if (candidate is num) return candidate.toInt();
    return int.tryParse(candidate?.toString().trim() ?? '');
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

  Future<Set<String>> _resolveCurrentIdentityNames() async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      Endpoints.me,
      decode: (dynamic data) {
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      },
    );

    if (result is! Success<Map<String, dynamic>>) return <String>{};
    final data = result.value;
    return <String>{
      (data['name'] ?? '').toString().trim().toLowerCase(),
      (data['userName'] ?? '').toString().trim().toLowerCase(),
      (data['email'] ?? '').toString().trim().toLowerCase(),
    }..removeWhere((value) => value.isEmpty);
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
