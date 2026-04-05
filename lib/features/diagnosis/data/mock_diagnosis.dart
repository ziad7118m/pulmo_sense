import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';

export 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';

final List<DiagnosisItem> recordHistory = [
  DiagnosisItem(
    id: legacyDiagnosisItemId(
      dateTime: '10 May 2025 • 12:30 PM',
      diagnosis: 'COVID-19',
      percentage: 80,
    ),
    dateTime: '10 May 2025 • 12:30 PM',
    diagnosis: 'COVID-19',
    percentage: 80,
    audioSourceType: AudioSourceType.recorded,
  ),
  DiagnosisItem(
    id: legacyDiagnosisItemId(
      dateTime: '09 May 2025 • 11:10 AM',
      diagnosis: 'Normal',
      percentage: 20,
    ),
    dateTime: '09 May 2025 • 11:10 AM',
    diagnosis: 'Normal',
    percentage: 20,
    audioSourceType: AudioSourceType.recorded,
  ),
];

final List<DiagnosisItem> stethoscopeHistory = [
  DiagnosisItem(
    id: legacyDiagnosisItemId(
      dateTime: '08 May 2025 • 03:45 PM',
      diagnosis: 'Pneumonia',
      percentage: 70,
    ),
    dateTime: '08 May 2025 • 03:45 PM',
    diagnosis: 'Pneumonia',
    percentage: 70,
    audioSourceType: AudioSourceType.recorded,
  ),
];

final List<DiagnosisItem> xrayHistory = [
  DiagnosisItem(
    id: legacyDiagnosisItemId(
      dateTime: '07 May 2025 • 09:20 AM',
      diagnosis: 'Pneumonia',
      percentage: 80,
      imagePath: 'assets/images/lungs1.png',
    ),
    dateTime: '07 May 2025 • 09:20 AM',
    diagnosis: 'Pneumonia',
    percentage: 80,
    imagePath: 'assets/images/lungs1.png',
  ),
];
