import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/dtos/lung_risk_history_entry_dto.dart';

class LungRiskHistoryRemoteDataSource {
  final ApiClient _client;

  const LungRiskHistoryRemoteDataSource(this._client);

  Future<Result<List<LungRiskHistoryEntryDto>>> fetchHistory() async {
    FailureResult<List<LungRiskHistoryEntryDto>>? lastFailure;

    for (final path in _candidatePaths) {
      final result = await _client.get<List<LungRiskHistoryEntryDto>>(
        path,
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

      if (result is Success<List<LungRiskHistoryEntryDto>>) {
        return result;
      }

      if (result is FailureResult<List<LungRiskHistoryEntryDto>>) {
        lastFailure = result;
        if (!_shouldTryNext(result.failure)) {
          break;
        }
      }
    }

    return lastFailure ??
        const FailureResult<List<LungRiskHistoryEntryDto>>(
          AppFailure(
            type: FailureType.unknown,
            message: 'Failed to load lung risk history.',
          ),
        );
  }

  static const List<String> _candidatePaths = [
    Endpoints.lungRiskHistory,
    Endpoints.lungRisks,
  ];

  bool _shouldTryNext(AppFailure failure) {
    return failure.type == FailureType.notFound;
  }
}
