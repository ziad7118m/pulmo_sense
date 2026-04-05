import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_latest_diagnosis.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_exam_card.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class PatientHomeLatestExamsSection extends StatelessWidget {
  final DashboardLatestDiagnosis latestDiagnosis;
  final VoidCallback onStartRecord;
  final VoidCallback onStartXray;
  final VoidCallback? onOpenRecordDetails;
  final VoidCallback? onOpenXrayDetails;
  final VoidCallback? onOpenStethoscopeDetails;

  const PatientHomeLatestExamsSection({
    super.key,
    required this.latestDiagnosis,
    required this.onStartRecord,
    required this.onStartXray,
    this.onOpenRecordDetails,
    this.onOpenXrayDetails,
    this.onOpenStethoscopeDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardExamCard(
          kind: DiagnosisKind.record,
          title: 'Cough Recording',
          icon: Icons.mic_rounded,
          item: latestDiagnosis.latestRecord,
          onOpenDetails: onOpenRecordDetails,
          onStartExam: onStartRecord,
        ),
        const SizedBox(height: 12),
        DashboardExamCard(
          kind: DiagnosisKind.xray,
          title: 'Chest X-ray',
          icon: Icons.image_search_rounded,
          item: latestDiagnosis.latestXray,
          onOpenDetails: onOpenXrayDetails,
          onStartExam: onStartXray,
        ),
        const SizedBox(height: 12),
        DashboardExamCard(
          kind: DiagnosisKind.stethoscope,
          title: 'Stethoscope Audio',
          icon: Icons.graphic_eq_rounded,
          item: latestDiagnosis.latestStethoscope,
          onOpenDetails: onOpenStethoscopeDetails,
          ctaLabelOverride: 'Visit doctor',
          emptyMessageOverride:
              'Stethoscope audio is recorded by a doctor and sent to your account.',
          onStartExam: () {
            if (latestDiagnosis.latestStethoscope != null) return;
            AppTopMessage.error(
              context,
              'No stethoscope recording yet. Please visit a doctor with a stethoscope to record and send it to your account.',
            );
          },
        ),
      ],
    );
  }
}
