import 'package:hive/hive.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/hive_diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/storage/diagnosis_item_entity.dart';
import 'package:lung_diagnosis_app/features/diagnosis/data/mock_diagnosis.dart';

class SeedHistory {
  static const _boxFlags = 'app_flags';
  static const _seedKey = 'history_seeded_v1';

  static Future<void> runIfNeeded() async {
    final flags = await Hive.openBox(_boxFlags);
    final seeded = flags.get(_seedKey, defaultValue: false) as bool;
    if (seeded) return;

    // لو boxes فيها داتا بالفعل، ما نلمسش حاجة
    final record = await Hive.openBox<DiagnosisItemEntity>(
      HiveDiagnosisHistoryRepository.boxRecord,
    );
    final stetho = await Hive.openBox<DiagnosisItemEntity>(
      HiveDiagnosisHistoryRepository.boxStethoscope,
    );
    final xray = await Hive.openBox<DiagnosisItemEntity>(
      HiveDiagnosisHistoryRepository.boxXray,
    );

    if (record.isEmpty) {
      for (final item in recordHistory) {
        record.add(DiagnosisItemEntity.fromDomain(item));
      }
    }

    if (stetho.isEmpty) {
      for (final item in stethoscopeHistory) {
        stetho.add(DiagnosisItemEntity.fromDomain(item));
      }
    }

    if (xray.isEmpty) {
      for (final item in xrayHistory) {
        xray.add(DiagnosisItemEntity.fromDomain(item));
      }
    }

    await flags.put(_seedKey, true);
  }
}
