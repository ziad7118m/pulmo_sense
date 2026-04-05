import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';

class DiagnosisHistoryViewData {
  final String title;
  final List<DiagnosisItem> items;

  const DiagnosisHistoryViewData({
    required this.title,
    required this.items,
  });

  bool get isEmpty => items.isEmpty;
}
