import 'package:lung_diagnosis_app/features/profile/data/local_profile.dart';
import 'package:lung_diagnosis_app/features/profile/data/local_profile_store.dart';

class ProfileLocalDataSource {
  final LocalProfileStore _store;

  const ProfileLocalDataSource(this._store);

  Future<LocalProfile?> getProfile(String userId) => _store.getProfile(userId);

  Future<LocalProfile> getOrCreate(String userId) => _store.getOrCreate(userId);

  Future<void> upsert(LocalProfile profile) => _store.upsert(profile);

  Future<void> deleteProfile(String userId) => _store.deleteProfile(userId);

  Future<String?> findUserIdByNationalId(String nationalId) =>
      _store.findUserIdByNationalId(nationalId);
}
