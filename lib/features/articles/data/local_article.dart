class LocalArticle {
  final String id;
  final String doctorName;
  final String title;
  final String content;
  final String? doctorImage;
  // Backward compatible: old data used a single "articleImage".
  // New UI supports up to 3 images.
  final List<String> articleImages;
  final String? articleImage; // legacy
  final DateTime createdAt;
  final String createdByUserId;

  /// Admin-only moderation toggle.
  /// When true, the article is hidden from doctors/patients and cannot be re-enabled by the author.
  final bool isHiddenByAdmin;

  const LocalArticle({
    required this.id,
    required this.doctorName,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.createdByUserId,
    this.isHiddenByAdmin = false,
    this.doctorImage,
    this.articleImages = const <String>[],
    this.articleImage,
  });

  String get preview {
    final t = content.trim();
    if (t.length <= 90) return t;
    return '${t.substring(0, 90)}...';
  }

  Map<String, dynamic> toMap() => {
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

  static LocalArticle fromMap(Map m) {
    final dynamic imgsRaw = m['articleImages'];
    final List<String> imgs = (imgsRaw is List)
        ? imgsRaw
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList()
        : <String>[];

    // legacy
    final legacy = m['articleImage']?.toString();
    final List<String> merged = [...imgs];
    if (merged.isEmpty && legacy != null && legacy.trim().isNotEmpty) {
      merged.add(legacy);
    }

    return LocalArticle(
      id: (m['id'] ?? '').toString(),
      doctorName: (m['doctorName'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),
      content: (m['content'] ?? '').toString(),
      doctorImage: m['doctorImage']?.toString(),
      articleImages: merged,
      articleImage: legacy,
      createdAt: DateTime.tryParse((m['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      createdByUserId: (m['createdByUserId'] ?? '').toString(),
      isHiddenByAdmin: (m['isHiddenByAdmin'] == true) || (m['isHiddenByAdmin']?.toString() == 'true'),
    );
  }
}