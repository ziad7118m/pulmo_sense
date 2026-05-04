import 'dart:convert';

import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/network/multipart_helper.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/data/dto/diagnosis_result_dto.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/value_objects/diagnosis_upload_request.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DiagnosisRemoteDataSource {
  final ApiClient _client;

  const DiagnosisRemoteDataSource(this._client);

  Future<Result<DiagnosisResultDto>> analyze(DiagnosisUploadRequest request) async {
    final endpoint = switch (request.kind) {
      DiagnosisKind.record => Endpoints.analyzeRecord,
      DiagnosisKind.stethoscope => Endpoints.analyzeAudio,
      DiagnosisKind.xray => Endpoints.analyzeXray,
    };

    final formData = await MultipartHelper.singleFile(
      // Swagger audio endpoints use different multipart field names:
      // Cough/analyze      -> audio
      // Stethoscope/analyze -> Audio
      // XRay/xray          -> image
      fieldName: switch (request.kind) {
        DiagnosisKind.record => 'audio',
        DiagnosisKind.stethoscope => 'Audio',
        DiagnosisKind.xray => 'image',
      },
      filePath: request.filePath,
      fields: {
        // Stethoscope API expects patientId only when the doctor sends the
        // recording for a selected patient.
        if (request.kind == DiagnosisKind.stethoscope &&
            (request.targetPatientId ?? '').trim().isNotEmpty)
          'patientId': request.targetPatientId!.trim(),
      },
    );

    return _client.postMultipart<DiagnosisResultDto>(
      endpoint,
      formData: formData,
      decode: (data) => DiagnosisResultDto.fromJson(_asJsonMap(data)),
    );
  }

  static Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('Invalid diagnosis response format');
  }
}
