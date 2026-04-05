import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/dtos/medical_profile_dto.dart';

class MedicalProfileRemoteDataSource {
  final ApiClient _client;

  const MedicalProfileRemoteDataSource(this._client);

  String _path(String ownerId) => '${Endpoints.medicalProfiles}/${ownerId.trim()}';

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Future<MedicalProfileDto?> getProfile(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return null;

    final result = await _client.get<MedicalProfileDto>(
      _path(normalized),
      decode: (data) => MedicalProfileDto.fromJson(_extractMap(data)),
    );

    if (result is Success<MedicalProfileDto>) {
      return result.value;
    }
    return null;
  }

  Future<void> saveProfile(MedicalProfileDto profile) async {
    final normalized = profile.ownerId.trim();
    if (normalized.isEmpty) return;

    await _client.put<dynamic>(
      _path(normalized),
      body: profile.toJson(),
    );
  }

  Future<void> deleteProfile(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return;
    await _client.delete<dynamic>(_path(normalized));
  }
}
