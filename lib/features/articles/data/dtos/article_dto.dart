class ArticleDto {
  final String id;
  final String doctorName;
  final String title;
  final String content;
  final String doctorImage;
  final List<String> articleImages;
  final String articleImage;
  final DateTime createdAt;
  final String createdByUserId;
  final bool isHiddenByAdmin;

  const ArticleDto({
    required this.id,
    required this.doctorName,
    required this.title,
    required this.content,
    required this.doctorImage,
    required this.articleImages,
    required this.articleImage,
    required this.createdAt,
    required this.createdByUserId,
    required this.isHiddenByAdmin,
  });

  factory ArticleDto.fromJson(Map<String, dynamic> json) {
    final nestedAuthor =
        _asMap(json['author']) ?? _asMap(json['doctor']) ?? _asMap(json['createdBy']);
    final images = _extractImages(json);
    final primaryImage = _firstNonEmpty(
      <String?>[
        json['articleImage']?.toString(),
        json['imageUrl']?.toString(),
        json['thumbnailUrl']?.toString(),
        images.isEmpty ? null : images.first,
      ],
    );

    return ArticleDto(
      id: _firstNonEmpty(<String?>[
            json['id']?.toString(),
            json['articleId']?.toString(),
          ]) ??
          '',
      doctorName: _firstNonEmpty(<String?>[
            json['doctorName']?.toString(),
            json['authorName']?.toString(),
            json['createdByName']?.toString(),
            _stringFromMap(nestedAuthor, 'displayName'),
            _stringFromMap(nestedAuthor, 'name'),
          ]) ??
          '',
      title: _firstNonEmpty(<String?>[
            json['title']?.toString(),
            json['headline']?.toString(),
          ]) ??
          '',
      content: _firstNonEmpty(<String?>[
            json['content']?.toString(),
            json['body']?.toString(),
            json['description']?.toString(),
          ]) ??
          '',
      doctorImage: _normalizeUrl(_firstNonEmpty(<String?>[
            json['doctorImage']?.toString(),
            json['authorAvatarUrl']?.toString(),
            json['doctorAvatarUrl']?.toString(),
            _stringFromMap(nestedAuthor, 'avatarUrl'),
            _stringFromMap(nestedAuthor, 'avatarPath'),
          ])) ??
          '',
      articleImages: images,
      articleImage: _normalizeUrl(primaryImage) ?? '',
      createdAt: DateTime.tryParse(
            _firstNonEmpty(<String?>[
                  json['createdAt']?.toString(),
                  json['publishedAt']?.toString(),
                  json['createdOn']?.toString(),
                ]) ??
                '',
          ) ??
          DateTime.now(),
      createdByUserId: _firstNonEmpty(<String?>[
            json['createdByUserId']?.toString(),
            json['authorUserId']?.toString(),
            json['doctorId']?.toString(),
            json['userId']?.toString(),
            _stringFromMap(nestedAuthor, 'id'),
            _stringFromMap(nestedAuthor, 'userId'),
          ]) ??
          '',
      isHiddenByAdmin: _parseBool(
        json['isHiddenByAdmin'] ??
            json['hiddenByAdmin'] ??
            json['isHidden'] ??
            json['hidden'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'doctorName': doctorName,
      'title': title,
      'content': content,
      'doctorImage': doctorImage,
      'articleImages': articleImages,
      'articleImage': articleImage,
      'createdAt': createdAt.toIso8601String(),
      'createdByUserId': createdByUserId,
      'isHiddenByAdmin': isHiddenByAdmin,
    };
  }

  static List<String> _extractImages(Map<String, dynamic> json) {
    final dynamic raw =
        json['articleImages'] ?? json['images'] ?? json['imageUrls'] ?? json['mediaUrls'];
    if (raw is List) {
      return raw
          .map<String?>((dynamic item) {
            if (item is Map<String, dynamic>) {
              return _normalizeUrl(
                _firstNonEmpty(<String?>[
                  item['imageUrl']?.toString(),
                  item['url']?.toString(),
                  item['path']?.toString(),
                ]),
              );
            }
            if (item is Map) {
              final map = Map<String, dynamic>.from(item);
              return _normalizeUrl(
                _firstNonEmpty(<String?>[
                  map['imageUrl']?.toString(),
                  map['url']?.toString(),
                  map['path']?.toString(),
                ]),
              );
            }
            return _normalizeUrl(item.toString());
          })
          .whereType<String>()
          .where((String item) => item.trim().isNotEmpty)
          .toList(growable: false);
    }

    final single = _normalizeUrl(_firstNonEmpty(<String?>[
      json['articleImage']?.toString(),
      json['imageUrl']?.toString(),
      json['thumbnailUrl']?.toString(),
    ]));
    return (single == null || single.isEmpty) ? const <String>[] : <String>[single];
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String? _stringFromMap(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    return map[key]?.toString();
  }

  static String? _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      final normalized = (value ?? '').trim();
      if (normalized.isNotEmpty) return normalized;
    }
    return null;
  }

  static String? _normalizeUrl(String? value) {
    final normalized = (value ?? '').trim();
    if (normalized.isEmpty) return null;
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }
    if (normalized.startsWith('/')) {
      return 'https://lungcare.runasp.net$normalized';
    }
    return normalized;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    final normalized = (value ?? '').toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}
