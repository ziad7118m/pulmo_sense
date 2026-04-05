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
}
