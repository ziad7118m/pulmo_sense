import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/helpers/admin_user_details_resolver.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_user_details_data.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';

class AdminUserDetailsPageController extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final ArticleController _articleController;

  AdminUserDetailsData? _data;
  bool _isLoading = false;
  String? _errorMessage;
  AuthUser? _lastUser;

  AdminUserDetailsPageController({
    required ProfileRepository profileRepository,
    required ArticleController articleController,
  }) : _profileRepository = profileRepository,
       _articleController = articleController;

  AdminUserDetailsData? get data => _data;
  bool get isLoading => _isLoading;
  bool get hasData => _data != null;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.trim().isNotEmpty;

  Future<void> load(AuthUser user) async {
    _lastUser = user;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await loadAdminUserDetailsData(
        user: user,
        profileRepository: _profileRepository,
        articleController: _articleController,
      );
    } catch (_) {
      _data = null;
      _errorMessage = 'Failed to load user details. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    final user = _lastUser;
    if (user == null) return;
    await load(user);
  }
}
