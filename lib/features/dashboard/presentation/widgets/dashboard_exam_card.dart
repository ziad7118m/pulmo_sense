import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_exam_audio_preview.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_exam_empty_state.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_exam_header.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_exam_result_card.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DashboardExamCard extends StatelessWidget {
  final DiagnosisKind kind;
  final String title;
  final IconData icon;
  final DiagnosisItem? item;
  final VoidCallback? onOpenDetails;
  final VoidCallback? onStartExam;
  final String? emptyMessageOverride;
  final String? ctaLabelOverride;

  const DashboardExamCard({
    super.key,
    required this.kind,
    required this.title,
    required this.icon,
    this.item,
    this.onOpenDetails,
    this.onStartExam,
    this.emptyMessageOverride,
    this.ctaLabelOverride,
  });

  String get _typeLabel {
    switch (kind) {
      case DiagnosisKind.record:
        return 'Audio analysis';
      case DiagnosisKind.stethoscope:
        return 'Doctor recording';
      case DiagnosisKind.xray:
        return 'Imaging result';
    }
  }

  String get _emptyTitle {
    switch (kind) {
      case DiagnosisKind.record:
        return 'No cough recordings yet';
      case DiagnosisKind.stethoscope:
        return 'No stethoscope audios yet';
      case DiagnosisKind.xray:
        return 'No X-rays yet';
    }
  }

  String get _ctaLabel {
    final override = ctaLabelOverride?.trim() ?? '';
    if (override.isNotEmpty) return override;

    switch (kind) {
      case DiagnosisKind.record:
      case DiagnosisKind.stethoscope:
        return 'Start recording';
      case DiagnosisKind.xray:
        return 'Upload X-ray';
    }
  }

  bool get _showsAudioPreview => kind.isAudio;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exam = item;
    final bool hasItem = exam != null;
    final String date = exam?.dateTime ?? '';
    final String diagnosis = exam?.diagnosis ?? '';
    final double pct = exam?.percentage ?? 0;
    final List<double> audioSamples = item?.waveSamples ?? const <double>[];
    final String imagePath = item?.imagePath?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  scheme.surface,
                  scheme.surfaceVariant.withOpacity(0.78),
                ]
              : const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF4F9FF),
                ],
        ),
        border: Border.all(
          color: isDark
              ? scheme.outlineVariant.withOpacity(0.82)
              : const Color(0xFFD7E7FF),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: hasItem ? onOpenDetails : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardExamHeader(
                  title: title,
                  typeLabel: _typeLabel,
                  icon: icon,
                  hasItem: hasItem,
                  imagePath: kind.isImaging ? imagePath : null,
                ),
                const SizedBox(height: 12),
                if (!hasItem)
                  DashboardExamEmptyState(
                    title: _emptyTitle,
                    message: emptyMessageOverride ??
                        'Run this exam to generate your first result. It will appear here automatically.',
                    ctaLabel: onStartExam == null ? null : _ctaLabel,
                    onStartExam: onStartExam,
                  )
                else ...[
                  DashboardExamResultCard(
                    date: date,
                    diagnosis: diagnosis,
                    percentage: pct,
                  ),
                  if (_showsAudioPreview) ...[
                    const SizedBox(height: 12),
                    DashboardExamAudioPreview(
                      samples: audioSamples,
                      color: scheme.primary,
                      faintColor: scheme.primary.withOpacity(0.25),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
