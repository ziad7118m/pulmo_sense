import 'package:lung_diagnosis_app/features/profile/data/local_profile_store.dart';
import 'package:lung_diagnosis_app/features/profile/data/mappers/profile_mapper.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';

class LocalProfileRepository implements ProfileRepository {
  final LocalProfileStore _store;

  const LocalProfileRepository(this._store);

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final profile = await _store.getProfile(userId);
    if (profile == null) return null;
    return ProfileMapper.fromLocal(profile);
  }

  @override
  Future<UserProfile> getOrCreate(String userId) async {
    final profile = await _store.getOrCreate(userId);
    return ProfileMapper.fromLocal(profile);
  }

  @override
  Future<void> upsert(UserProfile profile) => _store.upsert(ProfileMapper.toLocal(profile));

  @override
  Future<void> deleteProfile(String userId) => _store.deleteProfile(userId);

  @override
  Future<String?> findUserIdByNationalId(String nationalId) =>
      _store.findUserIdByNationalId(nationalId);
}
