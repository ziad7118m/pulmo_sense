import 'dart:convert';

import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/dtos/audio_history_entry_dto.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class AudioHistoryRemoteDataSource {
  final ApiClient _client;

  const AudioHistoryRemoteDataSource(this._client);

  Future<Result<List<AudioHistoryEntryDto>>> fetchHistory(DiagnosisKind kind) {
    final endpoint = switch (kind) {
      DiagnosisKind.record => Endpoints.coughHistory,
      DiagnosisKind.stethoscope => Endpoints.stethoscopeHistory,
      DiagnosisKind.xray => throw ArgumentError('AudioHistoryRemoteDataSource does not support xray'),
    };

    return _client.get<List<AudioHistoryEntryDto>>(
      endpoint,
      decode: (data) {
        final decoded = data is String ? jsonDecode(data) : data;
        final list = decoded is List ? decoded : const [];
        return list
            .whereType<Map>()
            .map((item) => AudioHistoryEntryDto.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false);
      },
    );
  }
}
