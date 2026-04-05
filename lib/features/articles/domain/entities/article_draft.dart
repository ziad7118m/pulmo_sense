class ArticleDraft {
  final String authorUserId;
  final String authorName;
  final String? authorAvatarPath;
  final String title;
  final String content;
  final List<String> imagePaths;

  const ArticleDraft({
    required this.authorUserId,
    required this.authorName,
    required this.title,
    required this.content,
    this.authorAvatarPath,
    this.imagePaths = const <String>[],
  });

  bool get isValid =>
      authorUserId.trim().isNotEmpty &&
      authorName.trim().isNotEmpty &&
      title.trim().isNotEmpty &&
      content.trim().isNotEmpty;

  ArticleDraft copyWith({
    String? authorUserId,
    String? authorName,
    String? authorAvatarPath,
    String? title,
    String? content,
    List<String>? imagePaths,
  }) {
    return ArticleDraft(
      authorUserId: authorUserId ?? this.authorUserId,
      authorName: authorName ?? this.authorName,
      authorAvatarPath: authorAvatarPath ?? this.authorAvatarPath,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}
