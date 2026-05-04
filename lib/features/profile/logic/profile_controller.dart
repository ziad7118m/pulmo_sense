import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/models/edit_profile_seed.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/models/profile_screen_view_data.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);

  final ProfileRepository _repository;

  String? _userId;
  UserProfile? profile;
  bool isLoading = false;

  String? get userId => _userId;
  bool get hasProfile => profile != null;

  Future<void> setUserId(String? userId) async {
    final normalizedId = userId?.trim();
    if (_userId == normalizedId) return;
    _userId = normalizedId;

    if (_userId == null || _userId!.isEmpty) {
      profile = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    await loadProfile(_userId!, createIfMissing: true);
  }

  Future<UserProfile?> loadProfile(
    String userId, {
    bool createIfMissing = false,
  }) async {
    final normalizedId = userId.trim();
    if (normalizedId.isEmpty) return null;

    isLoading = true;
    notifyListeners();

    _userId = normalizedId;
    try {
      profile = createIfMissing
          ? await _repository.getOrCreate(normalizedId)
          : await _repository.getProfile(normalizedId);
      profile ??= UserProfile.empty(normalizedId);
    } catch (_) {
      profile = UserProfile.empty(normalizedId);
    }

    isLoading = false;
    notifyListeners();
    return profile;
  }

  Future<UserProfile?> current({
    bool createIfMissing = false,
    bool refresh = false,
  }) async {
    final id = _userId;
    if (id == null || id.trim().isEmpty) return null;
    if (!refresh && profile != null) return profile;
    return loadProfile(id, createIfMissing: createIfMissing);
  }

  Future<void> refresh() async {
    final id = _userId;
    if (id == null || id.trim().isEmpty) return;
    await loadProfile(id, createIfMissing: false);
  }

  Future<void> updateProfile(UserProfile updated) async {
    await _repository.upsert(updated);
    profile = updated;
    _userId = updated.userId;
    notifyListeners();
  }

  Future<void> updateAvatarPath(String newPath) async {
    final p = profile;
    if (p == null) return;

    if (newPath.isNotEmpty && !File(newPath).existsSync()) return;

    final updated = p.copyWith(
      avatarPath: newPath,
      updatedAt: DateTime.now(),
    );
    await updateProfile(updated);
  }

  ProfileScreenViewData? buildScreenViewData(AuthUser? user) {
    if (user == null) return null;

    final hasMatchingProfile = profile?.userId == user.id;
    final resolvedProfile = hasMatchingProfile
        ? (profile ?? UserProfile.empty(user.id))
        : UserProfile.empty(user.id);
    final busy = isLoading;

    return ProfileScreenViewData(
      user: user,
      profile: resolvedProfile,
      isLoading: busy,
    );
  }

  Future<EditProfileSeed?> loadEditSeed(AuthUser? user) async {
    if (user == null) return null;

    final resolvedProfile = profile?.userId == user.id
        ? profile
        : await loadProfile(user.id, createIfMissing: false);

    final currentProfile = resolvedProfile ?? UserProfile.empty(user.id);
    return EditProfileSeed.fromProfile(
      profile: currentProfile,
      displayName: user.displayName,
    );
  }

  String composeDisplayName({
    required String firstName,
    required String lastName,
  }) {
    return '$firstName $lastName'.trim();
  }

  Future<UserProfile> saveProfileForm({
    required AuthUser user,
    required String nationalId,
    required String address,
    required String phone,
    required String birthDate,
    required String gender,
    required String maritalStatus,
    required String doctorLicense,
    required File? avatarFile,
  }) async {
    final currentProfile = profile ??
        await current(refresh: true, createIfMissing: false) ??
        UserProfile.empty(user.id);

    final normalizedGender =
        gender.trim().isEmpty ? AppStrings.male : gender.trim();
    final normalizedMarital =
        maritalStatus.trim().isEmpty ? AppStrings.yes : maritalStatus.trim();

    final updated = currentProfile.copyWith(
      nationalId: nationalId.trim(),
      address: address.trim(),
      phone: phone.trim(),
      birthDate: birthDate.trim(),
      gender: normalizedGender,
      marital: normalizedMarital,
      doctorLicense: doctorLicense.trim(),
      avatarPath: avatarFile?.path ?? currentProfile.avatarPath,
      updatedAt: DateTime.now(),
    );

    await updateProfile(updated);
    return updated;
  }
}
