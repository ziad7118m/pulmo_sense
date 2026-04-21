import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/dtos/xray_history_entry_dto.dart';

class XrayHistoryRemoteDataSource {
  final ApiClient _client;

  const XrayHistoryRemoteDataSource(this._client);

  Future<Result<List<XrayHistoryEntryDto>>> fetchHistory() {
    return _client.get<List<XrayHistoryEntryDto>>(
      Endpoints.xrayHistory,
      decode: (dynamic data) {
        final List<dynamic> rawList = switch (data) {
          List _ => List<dynamic>.from(data),
          Map _ => List<dynamic>.from(
              (data['items'] ?? data['data'] ?? const <dynamic>[]) as List,
            ),
          _ => const <dynamic>[],
        };

        return rawList
            .whereType<Map>()
            .map<XrayHistoryEntryDto>(
              (item) => XrayHistoryEntryDto.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);
      },
    );
  }
}
