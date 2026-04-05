import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_disease_selector.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_section_header.dart';

class MedicalDiseasesSection extends StatelessWidget {
  final List<String> options;
  final String noneOption;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;

  const MedicalDiseasesSection({
    super.key,
    required this.options,
    required this.noneOption,
    required this.selectedValues,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MedicalSectionHeader(
          icon: Icons.medical_information_rounded,
          title: 'Diseases',
          subtitle:
              'Select one or more conditions, or choose No diseases if none apply.',
        ),
        const SizedBox(height: 12),
        MedicalDiseaseSelector(
          options: options,
          noneOption: noneOption,
          selectedValues: selectedValues,
          onToggle: onToggle,
        ),
        const SizedBox(height: 10),
        Text(
          'You must choose at least one option here before sending.',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
