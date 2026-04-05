import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_disease_tags_card.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_section_title.dart';

class MedicalProfileDiseasesSection extends StatelessWidget {
  final List<String> diseases;

  const MedicalProfileDiseasesSection({
    super.key,
    required this.diseases,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MedicalSectionTitle(
          icon: Icons.medical_information_rounded,
          title: 'Diseases',
          subtitle:
              'Known conditions and reported medical history for this account.',
        ),
        const SizedBox(height: 12),
        if (diseases.isEmpty)
          const EmptyStateCard(
            icon: Icons.healing_outlined,
            title: 'No diseases selected',
            message: 'This medical profile has no disease entries yet.',
          )
        else
          MedicalDiseaseTagsCard(diseases: diseases),
      ],
    );
  }
}
