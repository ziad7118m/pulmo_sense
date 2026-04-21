import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/session/session_context.dart';
import 'package:lung_diagnosis_app/features/profile/data/dtos/profile_dto.dart';

class ProfileRemoteDataSource {
  final ApiClient _client;
  bool _backendUnsupported = false;

  ProfileRemoteDataSource(this._client);

  String _userProfilePath(String userId) =>
      '${Endpoints.userProfile}/${userId.trim()}/profile';

  bool _isCurrentUser(String userId) {
    final requested = userId.trim();
    final current = (SessionContext.userId ?? '').trim();
    return requested.isNotEmpty && current.isNotEmpty && requested == current;
  }

  String _profilePath(String userId) {
    return _isCurrentUser(userId) ? Endpoints.myProfile : _userProfilePath(userId);
  }

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

  bool _isNotFound<T>(Result<T> result) {
    if (result is! FailureResult<T>) return false;
    return result.failure.type == FailureType.notFound || result.failure.statusCode == 404;
  }

  bool _isMethodNotAllowed<T>(Result<T> result) {
    if (result is! FailureResult<T>) return false;
    return result.failure.statusCode == 405;
  }

  void _throwIfFailed<T>(Result<T> result) {
    if (result is FailureResult<T>) {
      throw result.failure;
    }
  }

  Future<ProfileDto?> getProfile(String userId) async {
    if (_backendUnsupported) return null;

    final normalized = userId.trim();
    if (normalized.isEmpty) return null;

    final result = await _client.get<Map<String, dynamic>>(
      _profilePath(normalized),
      decode: (data) => _extractMap(data),
    );

    return result.when(
      success: (payload) {
        if (payload.isEmpty) return null;

        final dto = ProfileDto.fromJson(payload);
        if (dto.userId.trim().isNotEmpty) {
          return dto;
        }

        return ProfileDto(
          userId: normalized,
          nationalId: dto.nationalId,
          address: dto.address,
          phone: dto.phone,
          birthDate: dto.birthDate,
          gender: dto.gender,
          maritalStatus: dto.maritalStatus,
          doctorLicense: dto.doctorLicense,
          avatarPath: dto.avatarPath,
          updatedAt: dto.updatedAt,
        );
      },
      failure: (failure) {
        if (failure.type == FailureType.notFound || failure.statusCode == 404) {
          _backendUnsupported = true;
          return null;
        }
        return null;
      },
    );
  }

  Future<void> upsert(ProfileDto dto) async {
    if (_backendUnsupported) {
      throw const AppFailure(
        type: FailureType.notFound,
        statusCode: 404,
        message: 'Profile API is not available on the current backend.',
      );
    }

    final normalized = dto.userId.trim();
    if (normalized.isEmpty) return;
    final result = await _client.put<dynamic>(
      _profilePath(normalized),
      body: dto.toJson(),
    );

    if (_isNotFound(result) || _isMethodNotAllowed(result)) {
      _backendUnsupported = true;
    }
    _throwIfFailed(result);
  }

  Future<void> deleteProfile(String userId) async {
    if (_backendUnsupported) return;

    final normalized = userId.trim();
    if (normalized.isEmpty) return;
    final result = await _client.delete<dynamic>(_profilePath(normalized));

    if (_isNotFound(result) || _isMethodNotAllowed(result)) {
      _backendUnsupported = true;
      return;
    }
    _throwIfFailed(result);
  }

  Future<String?> findUserIdByNationalId(String nationalId) async {
    final normalized = nationalId.trim();
    if (normalized.isEmpty) return null;

    final result = await _client.get<Map<String, dynamic>>(
      Endpoints.doctorPatientResolve,
      query: {'nationalId': normalized},
      decode: (data) => _extractMap(data),
    );

    return result.when(
      success: (payload) {
        final nestedPatient = payload['patient'];
        if (nestedPatient is Map) {
          final patientMap = Map<String, dynamic>.from(nestedPatient);
          final nestedId =
              (patientMap['userId'] ?? patientMap['patientId'] ?? patientMap['id'] ?? '')
                  .toString()
                  .trim();
          if (nestedId.isNotEmpty) return nestedId;
        }

        final directId = (payload['userId'] ?? payload['patientId'] ?? payload['id'] ?? '')
            .toString()
            .trim();
        return directId.isEmpty ? null : directId;
      },
      failure: (_) => null,
    );
  }
}
