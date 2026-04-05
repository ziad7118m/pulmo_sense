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
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
