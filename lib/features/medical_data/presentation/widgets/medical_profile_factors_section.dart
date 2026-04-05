import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_factor_card.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_section_title.dart';

class MedicalProfileFactorsSection extends StatelessWidget {
  final List<MapEntry<String, double>> factors;

  const MedicalProfileFactorsSection({
    super.key,
    required this.factors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MedicalSectionTitle(
          icon: Icons.tune_rounded,
          title: 'Medical factors',
          subtitle:
              'All percentage-based factors that define the current medical profile.',
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: factors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => MedicalFactorCard(
            title: factors[index].key,
            percentage: factors[index].value,
          ),
        ),
      ],
    );
  }
}
