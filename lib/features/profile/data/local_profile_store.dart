import 'package:lung_diagnosis_app/features/profile/data/local_profile.dart';

class LocalProfileStore {
  static const String boxName = 'local_profiles';

  final Map<String, LocalProfile> _profiles = <String, LocalProfile>{};

  Future<LocalProfile?> getProfile(String userId) async {
    return _profiles[userId.trim()];
  }

  Future<LocalProfile> getOrCreate(String userId) async {
    final normalized = userId.trim();
    final existing = _profiles[normalized];
    if (existing != null) {
      return existing;
    }

    final empty = LocalProfile.empty(normalized);
    _profiles[normalized] = empty;
    return empty;
  }

  Future<void> upsert(LocalProfile profile) async {
    _profiles[profile.userId.trim()] = profile;
  }

  Future<void> deleteProfile(String userId) async {
    _profiles.remove(userId.trim());
  }

  Future<String?> findUserIdByPhone(String phone) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) return null;

    for (final profile in _profiles.values) {
      if (profile.phone.trim() == normalizedPhone &&
          profile.userId.trim().isNotEmpty) {
        return profile.userId.trim();
      }
    }

    return null;
  }

  Future<String?> findUserIdByNationalId(String nationalId) async {
    final normalizedId = nationalId.trim();
    if (normalizedId.isEmpty) return null;

    for (final profile in _profiles.values) {
      if (profile.nationalId.trim() == normalizedId &&
          profile.userId.trim().isNotEmpty) {
        return profile.userId.trim();
      }
    }

    return null;
  }
}
