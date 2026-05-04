import 'package:lung_diagnosis_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/profile/data/local_profile_store.dart';
import 'package:lung_diagnosis_app/features/profile/data/mappers/profile_mapper.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  final LocalProfileStore _local;

  const ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required LocalProfileStore local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return null;

    // Profile endpoints are not available on the current backend yet,
    // so the profile screen must work from local data only instead of
    // waiting on a missing API.
    final local = await _local.getProfile(normalized);
    return local == null ? null : ProfileMapper.fromLocal(local);
  }

  @override
  Future<UserProfile> getOrCreate(String userId) async {
    final normalized = userId.trim();
    return ProfileMapper.fromLocal(await _local.getOrCreate(normalized));
  }

  @override
  Future<void> upsert(UserProfile profile) async {
    await _local.upsert(ProfileMapper.toLocal(profile));
  }

  @override
  Future<void> deleteProfile(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return;
    await _local.deleteProfile(normalized);
  }

  @override
  Future<String?> findUserIdByNationalId(String nationalId) async {
    final normalized = nationalId.trim();
    if (normalized.isEmpty) return null;

    final remoteResult = await _remote.findUserIdByNationalId(normalized);
    if ((remoteResult ?? '').trim().isNotEmpty) {
      return remoteResult;
    }

    return _local.findUserIdByNationalId(normalized);
  }
}
