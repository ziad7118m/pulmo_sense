import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_latest_diagnosis.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_exam_card.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DashboardLatestDiagnosisSection extends StatelessWidget {
  final DashboardLatestDiagnosis latestDiagnosis;
  final bool isDoctor;
  final bool isReadOnly;
  final VoidCallback? onStartRecord;
  final VoidCallback? onStartXray;
  final VoidCallback? onStartStethoscope;
  final VoidCallback? onOpenRecordDetails;
  final VoidCallback? onOpenXrayDetails;
  final VoidCallback? onOpenStethoscopeDetails;

  const DashboardLatestDiagnosisSection({
    super.key,
    required this.latestDiagnosis,
    required this.isDoctor,
    this.isReadOnly = false,
    this.onStartRecord,
    this.onStartXray,
    this.onStartStethoscope,
    this.onOpenRecordDetails,
    this.onOpenXrayDetails,
    this.onOpenStethoscopeDetails,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = latestDiagnosis.hasAny
        ? 'Tap a card to open the full report.'
        : isReadOnly
            ? 'No saved results were found for this patient yet.'
            : 'No saved results yet — start your first exam below.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          icon: Icons.auto_graph_rounded,
          title: 'Latest diagnosis',
          subtitle: subtitle,
        ),
        const SizedBox(height: 12),
        DashboardExamCard(
          kind: DiagnosisKind.record,
          title: 'Cough Recording',
          icon: Icons.mic_rounded,
          item: latestDiagnosis.latestRecord,
          onOpenDetails: onOpenRecordDetails,
          onStartExam: onStartRecord,
          emptyMessageOverride: isReadOnly
              ? 'No cough recording has been saved for this patient account yet.'
              : null,
        ),
        const SizedBox(height: 12),
        DashboardExamCard(
          kind: DiagnosisKind.xray,
          title: 'Chest X-ray',
          icon: Icons.image_search_rounded,
          item: latestDiagnosis.latestXray,
          onOpenDetails: onOpenXrayDetails,
          onStartExam: onStartXray,
          emptyMessageOverride: isReadOnly
              ? 'No chest X-ray result has been linked to this patient account yet.'
              : null,
        ),
        const SizedBox(height: 12),
        DashboardExamCard(
          kind: DiagnosisKind.stethoscope,
          title: 'Stethoscope Audio',
          icon: Icons.graphic_eq_rounded,
          item: latestDiagnosis.latestStethoscope,
          onOpenDetails: onOpenStethoscopeDetails,
          ctaLabelOverride: isDoctor ? null : 'Visit doctor',
          emptyMessageOverride: isReadOnly
              ? 'No stethoscope recording has been sent to this patient account yet.'
              : isDoctor
                  ? null
                  : 'Stethoscope audio is recorded by a doctor and will appear here when one is added to your account.',
          onStartExam: isReadOnly ? null : onStartStethoscope,
        ),
      ],
    );
  }
}
