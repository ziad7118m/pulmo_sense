import 'package:lung_diagnosis_app/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:lung_diagnosis_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/profile/data/mappers/profile_mapper.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _local;
  final ProfileRemoteDataSource? _remote;

  const ProfileRepositoryImpl({
    required ProfileLocalDataSource local,
    ProfileRemoteDataSource? remote,
  }) : _local = local,
       _remote = remote;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return null;

    final remote = _remote;
    if (remote != null) {
      final remoteProfile = await remote.getProfile(normalized);
      if (remoteProfile != null) {
        final domain = ProfileMapper.toDomain(remoteProfile);
        await _local.upsert(ProfileMapper.toLocal(domain));
        return domain;
      }
    }

    final localProfile = await _local.getProfile(normalized);
    if (localProfile == null) return null;
    return ProfileMapper.fromLocal(localProfile);
  }

  @override
  Future<UserProfile> getOrCreate(String userId) async {
    final normalized = userId.trim();
    final resolved = await getProfile(normalized);
    if (resolved != null) return resolved;

    final localProfile = await _local.getOrCreate(normalized);
    return ProfileMapper.fromLocal(localProfile);
  }

  @override
  Future<void> upsert(UserProfile profile) async {
    final remote = _remote;
    if (remote != null) {
      await remote.upsert(ProfileMapper.toDto(profile));
    }
    await _local.upsert(ProfileMapper.toLocal(profile));
  }

  @override
  Future<void> deleteProfile(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return;

    final remote = _remote;
    if (remote != null) {
      await remote.deleteProfile(normalized);
    }
    await _local.deleteProfile(normalized);
  }

  @override
  Future<String?> findUserIdByNationalId(String nationalId) async {
    final normalized = nationalId.trim();
    if (normalized.isEmpty) return null;

    final remote = _remote;
    if (remote != null) {
      final remoteUserId = await remote.findUserIdByNationalId(normalized);
      if (remoteUserId != null && remoteUserId.trim().isNotEmpty) {
        return remoteUserId.trim();
      }
    }

    return _local.findUserIdByNationalId(normalized);
  }
}
