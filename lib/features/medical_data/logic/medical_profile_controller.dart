import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/repositories/medical_profile_repository.dart';

class MedicalProfileController extends ChangeNotifier {
  MedicalProfileController(this._repository);

  final MedicalProfileRepository _repository;

  String? _currentUserId;
  MedicalProfileRecord? currentProfile;
  bool isLoading = false;
  bool isSaving = false;

  String? get currentUserId => _currentUserId;
  bool get hasProfile => currentProfile != null;

  Future<void> setCurrentUserId(String? userId) async {
    final normalized = userId?.trim();
    if ((_currentUserId ?? '') == (normalized ?? '')) return;

    _currentUserId = normalized;
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      currentProfile = null;
      notifyListeners();
      return;
    }

    await refreshCurrent();
  }

  Future<MedicalProfileRecord?> refreshCurrent() async {
    final ownerId = _currentUserId;
    if (ownerId == null || ownerId.isEmpty) {
      currentProfile = null;
      notifyListeners();
      return null;
    }

    isLoading = true;
    notifyListeners();

    try {
      currentProfile = await _repository.getProfile(ownerId);
      return currentProfile;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<MedicalProfileRecord?> loadOwnerProfile(String ownerId) {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return Future.value(null);
    return _repository.getProfile(normalized);
  }

  Future<void> saveProfile(
    MedicalProfileRecord profile, {
    bool shouldRefreshCurrent = true,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      await _repository.saveProfile(profile);
      if (profile.ownerId == _currentUserId) {
        currentProfile = profile;
      }

      if (shouldRefreshCurrent && profile.ownerId == _currentUserId) {
        await refreshCurrent();
        return;
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfile(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return;

    await _repository.deleteProfile(normalized);
    if (normalized == _currentUserId) {
      currentProfile = null;
      notifyListeners();
    }
  }
}
