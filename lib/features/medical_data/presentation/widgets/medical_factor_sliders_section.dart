import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_factor_slider_card.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_section_header.dart';

class MedicalFactorSlidersSection extends StatelessWidget {
  final Map<String, double> factors;
  final ValueChanged<MapEntry<String, double>> onFactorChanged;

  const MedicalFactorSlidersSection({
    super.key,
    required this.factors,
    required this.onFactorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MedicalSectionHeader(
          icon: Icons.tune_rounded,
          title: 'Medical factors',
          subtitle:
              'These are the base percentage values that will stay consistent across dashboard and medical data page.',
        ),
        const SizedBox(height: 12),
        ...factors.entries.map(
          (factor) => MedicalFactorSliderCard(
            title: factor.key,
            value: factor.value,
            onChanged: (newValue) => onFactorChanged(
              MapEntry<String, double>(factor.key, newValue),
            ),
          ),
        ),
      ],
    );
  }
}
