import 'package:hive/hive.dart';
import 'package:lung_diagnosis_app/features/profile/data/local_profile.dart';

class LocalProfileStore {
  static const String boxName = 'local_profiles';

  Future<Box> _box() => Hive.openBox(boxName);

  Future<LocalProfile?> getProfile(String userId) async {
    final box = await _box();
    final v = box.get(userId);
    if (v == null) return null;
    if (v is Map) {
      final p = LocalProfile.fromMap(v);
      if (p.userId.isEmpty) {
        return p.copyWith(updatedAt: p.updatedAt).copyWith();
      }
      return p;
    }
    return null;
  }

  Future<LocalProfile> getOrCreate(String userId) async {
    final existing = await getProfile(userId);
    if (existing != null) return existing;
    final empty = LocalProfile.empty(userId);
    await upsert(empty);
    return empty;
  }

  Future<void> upsert(LocalProfile profile) async {
    final box = await _box();
    await box.put(profile.userId, profile.toMap());
  }

  Future<void> deleteProfile(String userId) async {
    final box = await _box();
    await box.delete(userId);
  }

  Future<String?> findUserIdByPhone(String phone) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) return null;

    final box = await _box();
    for (final key in box.keys) {
      final value = box.get(key);
      if (value is! Map) continue;
      try {
        final profile = LocalProfile.fromMap(value);
        if (profile.phone.trim() == normalizedPhone && profile.userId.trim().isNotEmpty) {
          return profile.userId.trim();
        }
      } catch (_) {}
    }

    return null;
  }

  /// Finds a userId by matching the stored nationalId (local-only).
  /// Returns null if no profile matches.
  Future<String?> findUserIdByNationalId(String nationalId) async {
    final nid = nationalId.trim();
    if (nid.isEmpty) return null;
    final box = await _box();
    for (final key in box.keys) {
      final v = box.get(key);
      if (v is Map) {
        try {
          final p = LocalProfile.fromMap(v);
          if (p.nationalId.trim() == nid && p.userId.trim().isNotEmpty) {
            return p.userId.trim();
          }
        } catch (_) {}
      }
    }
    return null;
  }
}
