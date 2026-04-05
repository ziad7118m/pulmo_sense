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
  String _hidePath(String id) => '${_articlePath(id)}/moderation/hide';
  String _unhidePath(String id) => '${_articlePath(id)}/moderation/unhide';
  String _favouriteTogglePath(String id) => '${_articlePath(id)}/favourite-toggle';
  String _saveTogglePath(String id) => '${_articlePath(id)}/save-toggle';

  Future<List<ArticleDto>> all() {
    return _getArticleList(
      Endpoints.articles,
      query: <String, dynamic>{'scope': 'all'},
    );
  }

  Future<List<ArticleDto>> allVisible() {
    return _getArticleList(
      Endpoints.articles,
      query: <String, dynamic>{'scope': 'visible'},
    );
  }

  Future<List<ArticleDto>> mine() => _getArticleList(Endpoints.articleMine);

  Future<List<ArticleDto>> byAuthor(String userId) {
    return _getArticleList(
      Endpoints.articles,
      query: <String, dynamic>{'authorUserId': userId.trim()},
    );
  }

  Future<List<ArticleDto>> favourites() => _getArticleList(Endpoints.articleFavourites);

  Future<List<ArticleDto>> saved() => _getArticleList(Endpoints.articleSaved);

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
    throw StateError('Failed to fetch remote article.');
  }

  Future<ArticleDto?> upsert(ArticleUpsertRequestDto request) async {
    final normalizedId = request.id.trim();
    final path = normalizedId.isEmpty ? Endpoints.articles : _articlePath(normalizedId);

    final Result<ArticleDto> result = normalizedId.isEmpty
        ? await _apiClient.post<ArticleDto>(
            path,
            body: request.toJson(),
            decode: (dynamic data) => ArticleDto.fromJson(_extractArticleMap(data)),
          )
        : await _apiClient.put<ArticleDto>(
            path,
            body: request.toJson(),
            decode: (dynamic data) => ArticleDto.fromJson(_extractArticleMap(data)),
          );

    if (result is Success<ArticleDto>) {
      return result.value;
    }
    throw StateError('Failed to persist remote article.');
  }

  Future<void> delete(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return;
    await _apiClient.delete<dynamic>(_articlePath(normalized));
  }

  Future<ArticleDto?> setAdminHidden(String articleId, bool hidden) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return null;

    final Result<ArticleDto> result = await _apiClient.post<ArticleDto>(
      hidden ? _hidePath(normalized) : _unhidePath(normalized),
      decode: (dynamic data) => ArticleDto.fromJson(_extractArticleMap(data)),
    );

    if (result is Success<ArticleDto>) {
      return result.value;
    }
    throw StateError('Failed to update remote article moderation state.');
  }

  Future<ArticleReactionStatusDto?> reactionStatus(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return null;

    final Result<ArticleReactionStatusDto> result =
        await _apiClient.get<ArticleReactionStatusDto>(
      _articlePath(normalized),
      decode: (dynamic data) =>
          ArticleReactionStatusDto.fromJson(_extractStateMap(data)),
    );

    if (result is Success<ArticleReactionStatusDto>) {
      return result.value;
    }
    throw StateError('Failed to fetch remote article reaction state.');
  }

  Future<ArticleReactionStatusDto?> toggleFavourite(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return null;

    final Result<ArticleReactionStatusDto> result =
        await _apiClient.post<ArticleReactionStatusDto>(
      _favouriteTogglePath(normalized),
      decode: (dynamic data) =>
          ArticleReactionStatusDto.fromJson(_extractStateMap(data)),
    );

    if (result is Success<ArticleReactionStatusDto>) {
      return result.value;
    }
    throw StateError('Failed to toggle remote article favourite state.');
  }

  Future<ArticleReactionStatusDto?> toggleSaved(String articleId) async {
    final normalized = articleId.trim();
    if (normalized.isEmpty) return null;

    final Result<ArticleReactionStatusDto> result =
        await _apiClient.post<ArticleReactionStatusDto>(
      _saveTogglePath(normalized),
      decode: (dynamic data) =>
          ArticleReactionStatusDto.fromJson(_extractStateMap(data)),
    );

    if (result is Success<ArticleReactionStatusDto>) {
      return result.value;
    }
    throw StateError('Failed to toggle remote article saved state.');
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

  Map<String, dynamic> _extractStateMap(dynamic data) {
    final root = _extractMap(data);
    final nestedData = _asMap(root['data']);
    final nestedState = _mapValue(nestedData, 'viewerState') ??
        _mapValue(nestedData, 'state') ??
        _mapValue(root, 'viewerState') ??
        _mapValue(root, 'state');
    return nestedState ?? nestedData ?? root;
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
