import 'package:lung_diagnosis_app/core/utils/local_file_utils.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/home/presentation/models/diagnosis_details_view_data.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DiagnosisDetailsController {
  final DiagnosisHistoryRepository historyRepository;
  final DiagnosisKind kind;
  final DiagnosisItem item;
  final String? ownerUserId;

  const DiagnosisDetailsController({
    required this.historyRepository,
    required this.kind,
    required this.item,
    this.ownerUserId,
  });

  DiagnosisDetailsViewData buildViewData() {
    final audioPath = (item.audioPath ?? '').trim();
    final imagePath = (item.imagePath ?? '').trim();
    final normalizedOwnerUserId = ownerUserId?.trim();
    final lastResult = historyRepository.getLastResultByKind(
      kind,
      ownerUserId: (normalizedOwnerUserId == null || normalizedOwnerUserId.isEmpty)
          ? null
          : normalizedOwnerUserId,
    );

    return DiagnosisDetailsViewData(
      kind: kind,
      result: lastResult ?? _fallbackResult(),
      hasAudio: kind.isAudio && audioPath.isNotEmpty,
      hasImage: kind.isImaging && imagePath.isNotEmpty,
      audioPath: audioPath.isEmpty ? null : audioPath,
    );
  }

  Future<void> deleteItem() async {
    await LocalFileUtils.deleteIfExists(item.audioPath);
    await LocalFileUtils.deleteIfExists(item.imagePath);
    final normalizedOwnerUserId = ownerUserId?.trim();
    await historyRepository.deleteItemByKind(
      kind,
      item.id,
      ownerUserId: (normalizedOwnerUserId == null || normalizedOwnerUserId.isEmpty)
          ? null
          : normalizedOwnerUserId,
    );
  }

  DiagnosisResult _fallbackResult() {
    return DiagnosisResult(
      riskLevel: item.diagnosis,
      confidence: (item.percentage / 100).clamp(0, 1).toDouble(),
      recommendation: 'Follow medical guidance if symptoms persist.',
    );
  }
}
