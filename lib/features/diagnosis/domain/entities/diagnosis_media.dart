import 'package:lung_diagnosis_app/shared/domain/enums/media_source_type.dart';

class DiagnosisMedia {
  final String? localPath;
  final String? remoteUrl;
  final String? fileId;
  final MediaSourceType sourceType;

  const DiagnosisMedia({
    required this.sourceType,
    this.localPath,
    this.remoteUrl,
    this.fileId,
  });
}
