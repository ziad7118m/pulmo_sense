import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DiagnosisDetailsViewData {
  final DiagnosisKind kind;
  final DiagnosisResult result;
  final bool hasAudio;
  final bool hasImage;
  final String? audioPath;

  const DiagnosisDetailsViewData({
    required this.kind,
    required this.result,
    required this.hasAudio,
    required this.hasImage,
    required this.audioPath,
  });

  String get type => kind.storageKey;
  String get readOnlyMediaLabel => kind.isImaging ? 'X-ray' : 'audio';
}
