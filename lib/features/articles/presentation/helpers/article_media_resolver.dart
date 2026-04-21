import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:provider/provider.dart';

class ArticleMediaResolver {
  const ArticleMediaResolver._();

  static String resolveDoctorImage({
    required BuildContext context,
    required Article article,
    bool preferCurrentUserAvatar = true,
  }) {
    return resolveDoctorImageForUserContext(
      article: article,
      currentUserId: context.read<AuthController>().currentUserId,
      currentUserAvatarPath: context.read<ProfileController>().profile?.avatarPath ?? '',
      preferCurrentUserAvatar: preferCurrentUserAvatar,
    );
  }

  static String resolveDoctorImageForUserContext({
    required Article article,
    required String? currentUserId,
    required String currentUserAvatarPath,
    bool preferCurrentUserAvatar = true,
  }) {
    if (preferCurrentUserAvatar) {
      final uid = (currentUserId ?? '').trim();
      final avatarPath = currentUserAvatarPath.trim();
      if (uid.isNotEmpty && article.createdByUserId == uid) {
        if (_isDisplayablePath(avatarPath)) {
          return avatarPath;
        }
      }
    }

    final stored = (article.doctorImage ?? '').trim();
    if (_isDisplayablePath(stored)) return stored;

    return '';
  }

  static String resolveArticleImage(Article article) {
    final imgs = article.articleImages;
    if (imgs.isNotEmpty) {
      final p = imgs.first.trim();
      if (_isDisplayablePath(p)) {
        return p;
      }
    }

    final legacy = (article.articleImage ?? '').trim();
    if (_isDisplayablePath(legacy)) {
      return legacy;
    }

    return '';
  }

  static List<String> galleryImages(Article article, {int max = 3}) {
    final List<String> imgs = [...article.articleImages]
        .map((e) => e.trim())
        .where(_isDisplayablePath)
        .toList();

    if (imgs.isEmpty) {
      final legacy = (article.articleImage ?? '').trim();
      if (_isDisplayablePath(legacy)) imgs.add(legacy);
    }

    return imgs.take(max).toList();
  }

  static String resolveCurrentDoctorAvatar(BuildContext context) {
    final avatarPath = (context.read<ProfileController>().profile?.avatarPath ?? '').trim();
    return _isDisplayablePath(avatarPath) ? avatarPath : '';
  }

  static bool _isDisplayablePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return true;
    if (trimmed.startsWith('assets/')) return true;
    return File(trimmed).existsSync();
  }
}
