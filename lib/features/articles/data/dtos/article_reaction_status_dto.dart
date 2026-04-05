class ArticleReactionStatusDto {
  final bool? isFavourite;
  final bool? isSaved;
  final int? favouriteCount;

  const ArticleReactionStatusDto({
    this.isFavourite,
    this.isSaved,
    this.favouriteCount,
  });

  factory ArticleReactionStatusDto.fromJson(Map<String, dynamic> json) {
    final nestedViewerState = _asMap(json['viewerState']) ?? _asMap(json['state']);
    final source = nestedViewerState ?? json;

    return ArticleReactionStatusDto(
      isFavourite: _parseNullableBool(
        source['isFavourite'] ?? source['favourite'] ?? source['liked'],
      ),
      isSaved: _parseNullableBool(
        source['isSaved'] ?? source['saved'] ?? source['bookmarked'],
      ),
      favouriteCount: _parseNullableInt(
        source['favouriteCount'] ?? source['favoritesCount'] ?? source['likesCount'],
      ),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static bool? _parseNullableBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') return true;
    if (normalized == 'false' || normalized == '0' || normalized == 'no') return false;
    return null;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString().trim());
  }
}
