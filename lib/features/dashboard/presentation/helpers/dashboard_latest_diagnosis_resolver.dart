import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_latest_diagnosis.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

DashboardLatestDiagnosis resolveDashboardLatestDiagnosis({
  required DiagnosisHistoryRepository historyRepository,
  required bool isDoctor,
  String? userId,
}) {
  DiagnosisItem? latestRecord;
  DiagnosisItem? latestXray;
  DiagnosisItem? latestStethoscope;

  try {
    latestRecord = _latestFor(historyRepository, DiagnosisKind.record, userId);
  } catch (_) {}

  try {
    latestXray = _latestFor(historyRepository, DiagnosisKind.xray, userId);
  } catch (_) {}

  try {
    final stethoscopeHistory =
        _historyFor(historyRepository, DiagnosisKind.stethoscope, userId);
    if (isDoctor) {
      for (final item in stethoscopeHistory) {
        if ((item.targetPatientId ?? '').trim().isEmpty) {
          latestStethoscope = item;
          break;
        }
      }
    } else {
      latestStethoscope = stethoscopeHistory.isEmpty ? null : stethoscopeHistory.first;
    }
  } catch (_) {}

  return DashboardLatestDiagnosis(
    latestRecord: latestRecord,
    latestXray: latestXray,
    latestStethoscope: latestStethoscope,
  );
}

DiagnosisItem _latestFor(
  DiagnosisHistoryRepository historyRepository,
  DiagnosisKind kind,
  String? userId,
) {
  final normalizedUserId = (userId ?? '').trim();

  if (normalizedUserId.isNotEmpty) {
    return historyRepository.getLatestByKindForUser(kind, normalizedUserId);
  }

  return historyRepository.getLatestByKind(kind);
}

List<DiagnosisItem> _historyFor(
  DiagnosisHistoryRepository historyRepository,
  DiagnosisKind kind,
  String? userId,
) {
  final normalizedUserId = (userId ?? '').trim();

  if (normalizedUserId.isNotEmpty) {
    return historyRepository.getHistoryByKindForUser(kind, normalizedUserId);
  }

  return historyRepository.getHistoryByKind(kind);
}
