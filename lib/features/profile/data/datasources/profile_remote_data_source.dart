import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/profile/data/dtos/profile_dto.dart';

class ProfileRemoteDataSource {
  final ApiClient _client;

  const ProfileRemoteDataSource(this._client);

  String _profilePath(String userId) => '${Endpoints.userProfile}/${userId.trim()}/profile';

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

  Future<ProfileDto?> getProfile(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return null;

    final result = await _client.get<ProfileDto>(
      _profilePath(normalized),
      decode: (data) => ProfileDto.fromJson(_extractMap(data)),
    );

    if (result is Success<ProfileDto>) {
      return result.value;
    }
    return null;
  }

  Future<void> upsert(ProfileDto dto) async {
    final normalized = dto.userId.trim();
    if (normalized.isEmpty) return;
    await _client.put<dynamic>(
      _profilePath(normalized),
      body: dto.toJson(),
    );
  }

  Future<void> deleteProfile(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return;
    await _client.delete<dynamic>(_profilePath(normalized));
  }

  Future<String?> findUserIdByNationalId(String nationalId) async {
    final normalized = nationalId.trim();
    if (normalized.isEmpty) return null;

    final result = await _client.get<Map<String, dynamic>>(
      Endpoints.doctorPatientResolve,
      query: {'nationalId': normalized},
      decode: (data) => _extractMap(data),
    );

    if (result is! Success<Map<String, dynamic>>) {
      return null;
    }

    final payload = result.value;
    final nestedPatient = payload['patient'];
    if (nestedPatient is Map) {
      final patientMap = Map<String, dynamic>.from(nestedPatient);
      final nestedId = (patientMap['userId'] ?? patientMap['patientId'] ?? patientMap['id'] ?? '')
          .toString()
          .trim();
      if (nestedId.isNotEmpty) return nestedId;
    }

    final directId = (payload['userId'] ?? payload['patientId'] ?? payload['id'] ?? '')
        .toString()
        .trim();
    return directId.isEmpty ? null : directId;
  }
}
