import 'package:lung_diagnosis_app/core/failures/failure.dart';
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

  bool _shouldUseLocalFallback(Object error) {
    if (error is! AppFailure) return false;
    return error.type == FailureType.notFound || error.statusCode == 404 || error.statusCode == 405;
  }

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return null;

    final remoteProfile = await _remote.getProfile(normalized);
    if (remoteProfile != null) {
      final mapped = ProfileMapper.toDomain(remoteProfile);
      await _local.upsert(ProfileMapper.toLocal(mapped));
      return mapped;
    }

    final local = await _local.getProfile(normalized);
    return local == null ? null : ProfileMapper.fromLocal(local);
  }

  @override
  Future<UserProfile> getOrCreate(String userId) async {
    final normalized = userId.trim();
    final resolved = await getProfile(normalized);
    return resolved ?? ProfileMapper.fromLocal(await _local.getOrCreate(normalized));
  }

  @override
  Future<void> upsert(UserProfile profile) async {
    try {
      await _remote.upsert(ProfileMapper.toDto(profile));
    } catch (error) {
      if (!_shouldUseLocalFallback(error)) rethrow;
    }
    await _local.upsert(ProfileMapper.toLocal(profile));
  }

  @override
  Future<void> deleteProfile(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return;

    try {
      await _remote.deleteProfile(normalized);
    } catch (error) {
      if (!_shouldUseLocalFallback(error)) rethrow;
    }
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
