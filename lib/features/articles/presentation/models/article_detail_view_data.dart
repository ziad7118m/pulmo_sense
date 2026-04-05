class ArticleDetailViewData {
  final bool isAdmin;
  final bool isOwner;
  final bool isFavorite;
  final bool isSaved;
  final int activeImageIndex;
  final bool isHiddenForCurrentUser;
  final String createdAtText;
  final String doctorImagePath;
  final List<String> images;
  final bool isDeleting;
  final bool isTogglingFavourite;
  final bool isTogglingSaved;

  const ArticleDetailViewData({
    required this.isAdmin,
    required this.isOwner,
    required this.isFavorite,
    required this.isSaved,
    required this.activeImageIndex,
    required this.isHiddenForCurrentUser,
    required this.createdAtText,
    required this.doctorImagePath,
    required this.images,
    required this.isDeleting,
    required this.isTogglingFavourite,
    required this.isTogglingSaved,
  });

  bool get isBusy => isDeleting || isTogglingFavourite || isTogglingSaved;
}
