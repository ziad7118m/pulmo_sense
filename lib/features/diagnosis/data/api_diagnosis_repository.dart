import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/data/datasources/diagnosis_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/diagnosis/data/dto/diagnosis_result_dto.dart';
import 'package:lung_diagnosis_app/features/diagnosis/data/mappers/diagnosis_mappers.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/repositories/diagnosis_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/value_objects/diagnosis_upload_request.dart';

class ApiDiagnosisRepository implements DiagnosisRepository {
  final DiagnosisRemoteDataSource _remote;

  ApiDiagnosisRepository(ApiClient client)
      : _remote = DiagnosisRemoteDataSource(client);

  @override
  Future<Result<DiagnosisResult>> analyzeRecord(DiagnosisUploadRequest request) {
    return _analyze(request);
  }

  @override
  Future<Result<DiagnosisResult>> analyzeAudio(DiagnosisUploadRequest request) {
    return _analyze(request);
  }

  @override
  Future<Result<DiagnosisResult>> analyzeXray(DiagnosisUploadRequest request) {
    return _analyze(request);
  }

  Future<Result<DiagnosisResult>> _analyze(DiagnosisUploadRequest request) async {
    final Result<DiagnosisResultDto> result = await _remote.analyze(request);
    if (result is FailureResult<DiagnosisResultDto>) {
      return FailureResult<DiagnosisResult>(result.failure);
    }

    final dto = (result as Success<DiagnosisResultDto>).value;
    return Success(DiagnosisMappers.toDomain(dto));
  }
}
