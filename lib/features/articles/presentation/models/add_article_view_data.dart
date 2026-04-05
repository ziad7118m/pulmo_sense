import 'dart:io';

class AddArticleViewData {
  final bool isDoctor;
  final bool isPosting;
  final bool isPosted;
  final int maxImages;
  final String doctorName;
  final String avatarPath;
  final List<File> images;
  final String? errorMessage;

  const AddArticleViewData({
    required this.isDoctor,
    required this.isPosting,
    required this.isPosted,
    required this.maxImages,
    required this.doctorName,
    required this.avatarPath,
    required this.images,
    required this.errorMessage,
  });

  bool get canAddImages => images.length < maxImages;
  int get remainingImages => maxImages - images.length;
  bool get hasError => (errorMessage ?? '').trim().isNotEmpty;
}
