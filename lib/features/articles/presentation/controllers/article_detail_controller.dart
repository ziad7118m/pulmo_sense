import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/helpers/article_media_resolver.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/models/article_detail_view_data.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';
import 'package:flutter/widgets.dart';

class ArticleDetailController extends ChangeNotifier {
  ArticleDetailController({
    required Article article,
    required ArticleController articleController,
    required AuthController authController,
    required BuildContext context,
  })  : _article = article,
        _articleController = articleController,
        _authController = authController,
        _context = context;

  final Article _article;
  final ArticleController _articleController;
  final AuthController _authController;
  final BuildContext _context;

  bool _isFavorite = false;
  bool _isSaved = false;
  int _activeImageIndex = 0;
  bool _isDeleting = false;
  bool _isTogglingFavourite = false;
  bool _isTogglingSaved = false;

  Article get article => _article;

  bool get isAdmin => _authController.currentUser?.role == UserRole.admin;
  bool get isOwner => _authController.currentUser?.id == _article.createdByUserId;

  ArticleDetailViewData get viewData => ArticleDetailViewData(
        isAdmin: isAdmin,
        isOwner: isOwner,
        isFavorite: _isFavorite,
        isSaved: _isSaved,
        activeImageIndex: _activeImageIndex,
        isHiddenForCurrentUser: !isAdmin && _article.isHiddenByAdmin,
        createdAtText: DateFormat('MMM d, yyyy  h:mm a').format(_article.createdAt.toLocal()),
        doctorImagePath: ArticleMediaResolver.resolveDoctorImage(
          context: _context,
          article: _article,
        ),
        images: ArticleMediaResolver.galleryImages(_article),
        isDeleting: _isDeleting,
        isTogglingFavourite: _isTogglingFavourite,
        isTogglingSaved: _isTogglingSaved,
      );

  Future<void> initialize() async {
    final favourite = await _articleController.isFavourite(_article.id);
    final saved = await _articleController.isSaved(_article.id);
    _isFavorite = favourite;
    _isSaved = saved;
    notifyListeners();
  }

  void updateImageIndex(int index) {
    if (_activeImageIndex == index) return;
    _activeImageIndex = index;
    notifyListeners();
  }

  Future<bool> delete() async {
    if (_isDeleting) return false;
    _isDeleting = true;
    notifyListeners();

    try {
      await _articleController.delete(_article.id);
      return true;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavourite() async {
    if (_isTogglingFavourite) return _isFavorite;

    final previous = _isFavorite;
    _isFavorite = !previous;
    _isTogglingFavourite = true;
    notifyListeners();

    try {
      await _articleController.toggleFavourite(_article.id);
      return _isFavorite;
    } catch (_) {
      _isFavorite = previous;
      rethrow;
    } finally {
      _isTogglingFavourite = false;
      notifyListeners();
    }
  }

  Future<bool> toggleSaved() async {
    if (_isTogglingSaved) return _isSaved;

    final previous = _isSaved;
    _isSaved = !previous;
    _isTogglingSaved = true;
    notifyListeners();

    try {
      await _articleController.toggleSaved(_article.id);
      return _isSaved;
    } catch (_) {
      _isSaved = previous;
      rethrow;
    } finally {
      _isTogglingSaved = false;
      notifyListeners();
    }
  }
}
