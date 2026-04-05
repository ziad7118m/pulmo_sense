import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';

class DiagnosisLocalDataSource {
  final DiagnosisHistoryRepository _historyRepository;

  const DiagnosisLocalDataSource(this._historyRepository);

  DiagnosisResult? readLastResult(String type) {
    return _historyRepository.getLastResult(type);
  }

  void saveLastResult(String type, DiagnosisResult result) {
    _historyRepository.setLastResult(type, result);
  }
}
