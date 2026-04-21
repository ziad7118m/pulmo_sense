class Article {
  final String id;
  final String doctorName;
  final String title;
  final String content;
  final String? doctorImage;
  final List<String> articleImages;
  final String? articleImage;
  final DateTime createdAt;
  final String createdByUserId;
  final bool isHiddenByAdmin;

  const Article({
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
    final text = content.trim();
    if (text.length <= 90) return text;
    return '${text.substring(0, 90)}...';
  }

  Article copyWith({
    String? id,
    String? doctorName,
    String? title,
    String? content,
    String? doctorImage,
    List<String>? articleImages,
    String? articleImage,
    DateTime? createdAt,
    String? createdByUserId,
    bool? isHiddenByAdmin,
  }) {
    return Article(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      title: title ?? this.title,
      content: content ?? this.content,
      doctorImage: doctorImage ?? this.doctorImage,
      articleImages: articleImages ?? this.articleImages,
      articleImage: articleImage ?? this.articleImage,
      createdAt: createdAt ?? this.createdAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      isHiddenByAdmin: isHiddenByAdmin ?? this.isHiddenByAdmin,
    );
  }
}
