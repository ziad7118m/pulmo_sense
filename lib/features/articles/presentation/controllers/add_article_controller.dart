import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article_draft.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/models/add_article_view_data.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class AddArticleController extends ChangeNotifier {
  AddArticleController({
    required ArticleController articleController,
    required AuthController authController,
    required ProfileController profileController,
    this.maxImages = 3,
  })  : _articleController = articleController,
        _authController = authController,
        _profileController = profileController;

  final ArticleController _articleController;
  final AuthController _authController;
  final ProfileController _profileController;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final List<File> _images = <File>[];

  final int maxImages;
  bool _isPosting = false;
  bool _isPosted = false;
  String? _errorMessage;

  bool get isDoctor => _authController.currentUserRole == UserRole.doctor;
  bool get isPosting => _isPosting;
  bool get isPosted => _isPosted;
  bool get canAddImages => _images.length < maxImages;
  List<File> get images => List<File>.unmodifiable(_images);
  String? get errorMessage => _errorMessage;

  AddArticleViewData get viewData => AddArticleViewData(
        isDoctor: isDoctor,
        isPosting: _isPosting,
        isPosted: _isPosted,
        maxImages: maxImages,
        doctorName: _authController.currentUserName ?? AppStrings.drName,
        avatarPath: (_profileController.profile?.avatarPath ?? '').trim(),
        images: List<File>.unmodifiable(_images),
        errorMessage: _errorMessage,
      );

  int addImageFiles(Iterable<File> files) {
    final remaining = maxImages - _images.length;
    if (remaining <= 0) return 0;

    final toAdd = files.take(remaining).toList(growable: false);
    if (toAdd.isEmpty) return 0;

    _images.addAll(toAdd);
    notifyListeners();
    return toAdd.length;
  }

  bool addImageFile(File file) {
    if (!canAddImages) return false;
    _images.add(file);
    notifyListeners();
    return true;
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= _images.length) return;
    _images.removeAt(index);
    notifyListeners();
  }

  String? validate() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) return 'Title is required.';
    if (content.isEmpty) return 'Content is required.';
    return null;
  }

  void clearError() {
    if ((_errorMessage ?? '').isEmpty) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> post() async {
    final draft = _buildDraft();
    _errorMessage = null;
    _isPosting = true;
    notifyListeners();

    try {
      await _articleController.createFromDraft(draft);
      _isPosted = true;
      return true;
    } catch (error) {
      _errorMessage = _resolveErrorMessage(error);
      return false;
    } finally {
      _isPosting = false;
      notifyListeners();
    }
  }

  ArticleDraft _buildDraft() {
    return ArticleDraft(
      authorUserId: _authController.currentUserId ?? 'anonymous',
      authorName: _authController.currentUserName ?? 'Doctor',
      authorAvatarPath: (_profileController.profile?.avatarPath ?? '').trim(),
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      imagePaths: _images.map((file) => file.path).toList(growable: false),
    );
  }

  String _resolveErrorMessage(Object error) {
    final message = error.toString().trim();
    if (message.isEmpty) {
      return 'Unable to post article right now.';
    }

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }
    if (message.startsWith('StateError: ')) {
      return message.substring('StateError: '.length).trim();
    }
    return message;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
