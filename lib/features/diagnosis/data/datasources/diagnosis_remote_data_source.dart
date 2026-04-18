import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/network/multipart_helper.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/data/dto/diagnosis_result_dto.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/value_objects/diagnosis_upload_request.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/recipient_type.dart';

class DiagnosisRemoteDataSource {
  final ApiClient _client;

  const DiagnosisRemoteDataSource(this._client);

  Future<Result<DiagnosisResultDto>> analyze(DiagnosisUploadRequest request) async {
    final endpoint = switch (request.kind) {
      DiagnosisKind.record => Endpoints.analyzeRecord,
      DiagnosisKind.stethoscope => Endpoints.analyzeAudio,
      DiagnosisKind.xray => Endpoints.analyzeXray,
    };

    final isXray = request.kind == DiagnosisKind.xray;
    final formData = await MultipartHelper.singleFile(
      fieldName: isXray ? 'image' : 'file',
      filePath: request.filePath,
      fields: {
        if (!isXray) 'recipientType': request.recipientType.apiValue,
        if (!isXray && (request.targetPatientId ?? '').trim().isNotEmpty)
          'targetPatientId': request.targetPatientId!.trim(),
      },
    );

    return _client.postMultipart<DiagnosisResultDto>(
      endpoint,
      formData: formData,
      decode: (data) => DiagnosisResultDto.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
