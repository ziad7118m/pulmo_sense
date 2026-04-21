import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';

class DiagnosisDetailsResultCard extends StatelessWidget {
  final String type;
  final DiagnosisItem item;
  final DiagnosisResult result;
  final Widget? waveSection;

  const DiagnosisDetailsResultCard({
    super.key,
    required this.type,
    required this.item,
    required this.result,
    this.waveSection,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final confidence = (result.confidence * 100).clamp(0, 100);
    final isXray = type == 'xray';
    final primaryProbability = _resolvePrimaryProbability(result);
    final secondaryProbabilities = result.sortedProbabilities
        .where((entry) => !_sameLabel(entry.label, primaryProbability?.label ?? ''))
        .where((entry) => entry.value >= 0.01)
        .take(2)
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.surface,
            scheme.surfaceVariant.withOpacity(0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.dateTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.riskLevel,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: scheme.primary,
                      ),
                    ),
                    if (isXray) ...[
                      const SizedBox(height: 6),
                      Text(
                        _buildXraySummary(result, confidence.toDouble()),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${confidence.toStringAsFixed(0)}% confidence',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (type == 'stethoscope' &&
              (item.createdByDoctorId ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _MetaRow(
              icon: Icons.person_outline_rounded,
              label: 'Doctor ID',
              value: '${item.createdByDoctorId}',
            ),
          ],
          if (type == 'stethoscope' &&
              (item.targetPatientId ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _MetaRow(
              icon: Icons.badge_outlined,
              label: 'Patient',
              value: '${item.targetPatientName ?? item.targetPatientId}',
            ),
          ],
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 10,
              backgroundColor: scheme.surfaceVariant.withOpacity(0.48),
              color: scheme.primary,
            ),
          ),
          if (isXray && result.hasProbabilityBreakdown) ...[
            const SizedBox(height: 16),
            Text(
              'Scan breakdown',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _XrayKeyMetricCard(
              title: 'Most likely finding',
              value: primaryProbability?.label ?? result.riskLevel,
              caption: primaryProbability == null
                  ? '${confidence.toStringAsFixed(0)}% confidence'
                  : '${_formatPercent(primaryProbability.value)} probability',
            ),
            if (secondaryProbabilities.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...secondaryProbabilities.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ProbabilityRow(
                    label: entry.label,
                    value: entry.value,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surface.withOpacity(0.84),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.52),
                  ),
                ),
                child: Text(
                  'No other likely findings were detected above 1%.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 14),
          Text(
            'Clinical recommendation',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(0.84),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.52),
              ),
            ),
            child: Text(
              result.recommendation,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (waveSection != null) waveSection!,
        ],
      ),
    );
  }

  DiagnosisProbability? _resolvePrimaryProbability(DiagnosisResult result) {
    if (!result.hasProbabilityBreakdown) {
      return null;
    }

    for (final entry in result.sortedProbabilities) {
      if (_sameLabel(entry.label, result.riskLevel)) {
        return entry;
      }
    }

    final sorted = result.sortedProbabilities;
    if (sorted.isEmpty) {
      return null;
    }
    return sorted.first;
  }

  bool _sameLabel(String left, String right) {
    String normalize(String value) => value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return normalize(left) == normalize(right);
  }

  String _buildXraySummary(DiagnosisResult result, double confidence) {
    final normalizedRisk = result.riskLevel.trim().toLowerCase();
    final percentage = confidence.clamp(0, 100);

    if (normalizedRisk.contains('normal')) {
      return 'The scan looks close to normal with ${percentage.toStringAsFixed(0)}% confidence.';
    }
    if (normalizedRisk.contains('viral')) {
      return 'The model thinks viral pneumonia is the most likely finding.';
    }
    if (normalizedRisk.contains('opacity')) {
      return 'The scan suggests lung opacity and may need medical review.';
    }
    return 'This is the strongest finding detected by the scan analysis.';
  }

  static String _formatPercent(double value) {
    final percent = (value * 100).clamp(0.0, 100.0).toDouble();
    if (percent > 0 && percent < 0.1) {
      return '<0.1%';
    }
    if (percent >= 99.95) {
      return '100%';
    }
    if (percent < 1) {
      return '${percent.toStringAsFixed(1)}%';
    }
    return '${percent.toStringAsFixed(0)}%';
  }
}

class _XrayKeyMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;

  const _XrayKeyMetricCard({
    required this.title,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: scheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: TextStyle(
              fontSize: 12,
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProbabilityRow extends StatelessWidget {
  final String label;
  final double value;

  const _ProbabilityRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.84),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(0.52),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                DiagnosisDetailsResultCard._formatPercent(value),
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: scheme.surfaceVariant.withOpacity(0.48),
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: scheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
