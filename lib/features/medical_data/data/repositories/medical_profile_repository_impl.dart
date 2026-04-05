import 'package:lung_diagnosis_app/features/medical_data/data/datasources/medical_profile_local_data_source.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/datasources/medical_profile_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/mappers/medical_profile_mapper.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/repositories/medical_profile_repository.dart';

class MedicalProfileRepositoryImpl implements MedicalProfileRepository {
  final MedicalProfileLocalDataSource _local;
  final MedicalProfileRemoteDataSource? _remote;

  const MedicalProfileRepositoryImpl({
    required MedicalProfileLocalDataSource local,
    MedicalProfileRemoteDataSource? remote,
  }) : _local = local,
       _remote = remote;

  @override
  Future<MedicalProfileRecord?> getProfile(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return null;

    final remote = _remote;
    if (remote != null) {
      final remoteProfile = await remote.getProfile(normalized);
      if (remoteProfile != null) {
        final domain = MedicalProfileMapper.fromDto(remoteProfile);
        await _local.saveProfile(MedicalProfileMapper.toLocal(domain));
        return domain;
      }
    }

    final localProfile = await _local.getProfile(normalized);
    return localProfile == null ? null : MedicalProfileMapper.fromLocal(localProfile);
  }

  @override
  Future<void> saveProfile(MedicalProfileRecord profile) async {
    final remote = _remote;
    if (remote != null) {
      await remote.saveProfile(MedicalProfileMapper.toDto(profile));
    }
    await _local.saveProfile(MedicalProfileMapper.toLocal(profile));
  }

  @override
  Future<void> deleteProfile(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return;

    final remote = _remote;
    if (remote != null) {
      await remote.deleteProfile(normalized);
    }
    await _local.deleteProfile(normalized);
  }
}
