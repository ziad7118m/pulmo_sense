import 'package:lung_diagnosis_app/core/session/session_context.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/datasources/medical_profile_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/in_memory_medical_profile_store.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/mappers/medical_profile_mapper.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/repositories/medical_profile_repository.dart';

class MedicalProfileRepositoryImpl implements MedicalProfileRepository {
  final MedicalProfileRemoteDataSource _remote;
  final InMemoryMedicalProfileStore _cache;

  MedicalProfileRepositoryImpl({
    required MedicalProfileRemoteDataSource remote,
    required InMemoryMedicalProfileStore local,
  })  : _remote = remote,
        _cache = local;

  bool _isCurrentUser(String ownerId) {
    final normalized = ownerId.trim();
    final current = (SessionContext.userId ?? '').trim();
    return normalized.isNotEmpty && current.isNotEmpty && normalized == current;
  }

  @override
  Future<MedicalProfileRecord?> getProfile(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return null;
    if (!_isCurrentUser(normalized)) return null;

    final remoteProfile = await _remote.getProfile(normalized);
    if (remoteProfile == null) {
      await _cache.delete(normalized);
      return null;
    }

    final mapped = MedicalProfileMapper.fromDto(remoteProfile);
    await _cache.upsert(mapped);
    return mapped;
  }

  @override
  Future<void> saveProfile(MedicalProfileRecord profile) async {
    await _remote.saveProfile(MedicalProfileMapper.toDto(profile));
    await _cache.upsert(profile);
  }

  @override
  Future<void> deleteProfile(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return;

    await _remote.deleteProfile(normalized);
    await _cache.delete(normalized);
  }
}
