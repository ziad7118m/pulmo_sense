import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/risk_card_dashboard.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/services/lung_risk_analyzer.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_section_title.dart';

class MedicalOverallRiskSection extends StatefulWidget {
  final MedicalProfileRecord profile;

  const MedicalOverallRiskSection({
    super.key,
    required this.profile,
  });

  @override
  State<MedicalOverallRiskSection> createState() => _MedicalOverallRiskSectionState();
}

class _MedicalOverallRiskSectionState extends State<MedicalOverallRiskSection> {
  late Future<double> _riskFuture;

  @override
  void initState() {
    super.initState();
    _riskFuture = LungRiskAnalyzer.analyzeOverallRisk(widget.profile);
  }

  @override
  void didUpdateWidget(covariant MedicalOverallRiskSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.updatedAt != widget.profile.updatedAt ||
        !_sameFactors(oldWidget.profile.factors, widget.profile.factors) ||
        oldWidget.profile.backendHigh != widget.profile.backendHigh) {
      _riskFuture = LungRiskAnalyzer.analyzeOverallRisk(widget.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backendResult = widget.profile.backendResult?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicalSectionTitle(
          icon: Icons.analytics_rounded,
          title: 'Overall risk',
          subtitle: backendResult == null || backendResult.isEmpty
              ? 'Calculated from the latest saved medical factors.'
              : 'Based on the latest backend result: $backendResult.',
        ),
        const SizedBox(height: 12),
        FutureBuilder<double>(
          future: _riskFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _MedicalRiskLoadingCard();
            }

            final riskPercentage = snapshot.data ?? LungRiskAnalyzer.localFallback(widget.profile);
            return RiskDashboardCard(percentage: riskPercentage);
          },
        ),
      ],
    );
  }

  bool _sameFactors(Map<String, double> a, Map<String, double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}

class _MedicalRiskLoadingCard extends StatelessWidget {
  const _MedicalRiskLoadingCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.9)),
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.8),
        ),
      ),
    );
  }
}
