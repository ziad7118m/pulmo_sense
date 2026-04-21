import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/session/session_context.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/dtos/lung_risk_history_entry_dto.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/dtos/medical_profile_dto.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class MedicalProfileRemoteDataSource {
  final ApiClient _client;

  const MedicalProfileRemoteDataSource(this._client);

  bool _isCurrentUser(String ownerId) {
    final requested = ownerId.trim();
    final current = (SessionContext.userId ?? '').trim();
    return requested.isNotEmpty && current.isNotEmpty && requested == current;
  }

  Future<Result<List<LungRiskHistoryEntryDto>>> _fetchHistory() {
    return _client.get<List<LungRiskHistoryEntryDto>>(
      Endpoints.lungRiskHistory,
      decode: (dynamic data) {
        final List<dynamic> rawList = switch (data) {
          List _ => List<dynamic>.from(data),
          Map _ => List<dynamic>.from(
              (data['items'] ?? data['data'] ?? data['history'] ?? const <dynamic>[]) as List,
            ),
          _ => const <dynamic>[],
        };

        return rawList
            .whereType<Map>()
            .map<LungRiskHistoryEntryDto>(
              (item) => LungRiskHistoryEntryDto.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      },
    );
  }

  Future<MedicalProfileDto?> getProfile(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty || !_isCurrentUser(normalized)) {
      return null;
    }

    final result = await _fetchHistory();
    if (result is Success<List<LungRiskHistoryEntryDto>>) {
      final history = result.value;
      if (history.isEmpty) return null;
      return MedicalProfileDto.fromRiskHistory(
        history.first,
        ownerId: normalized,
        ownerRole: UserRoleX.fromValue(SessionContext.roleName ?? 'patient'),
      );
    }

    if (result is FailureResult<List<LungRiskHistoryEntryDto>>) {
      final failure = result.failure;
      if (failure.type == FailureType.notFound || failure.statusCode == 404) {
        return null;
      }
      throw failure;
    }

    return null;
  }

  Future<void> saveProfile(MedicalProfileDto profile) async {
    final normalized = profile.ownerId.trim();
    if (normalized.isEmpty) return;
    if (!_isCurrentUser(normalized)) {
      throw const AppFailure(
        type: FailureType.forbidden,
        statusCode: 403,
        message: 'The backend only supports saving lung risk data for the current account.',
      );
    }

    final result = await _client.post<dynamic>(
      Endpoints.lungRiskAnalyze,
      body: profile.toLungRiskRequestJson(),
      decode: (data) => data,
    );

    if (result is FailureResult<dynamic>) {
      throw result.failure;
    }
  }

  Future<void> deleteProfile(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return;
    if (!_isCurrentUser(normalized)) {
      throw const AppFailure(
        type: FailureType.forbidden,
        statusCode: 403,
        message: 'The backend does not expose deleting another account medical data.',
      );
    }
  }
}
