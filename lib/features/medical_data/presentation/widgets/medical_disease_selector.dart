import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_colors.dart';

class MedicalDiseaseSelector extends StatelessWidget {
  final List<String> options;
  final String noneOption;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;

  const MedicalDiseaseSelector({
    super.key,
    required this.options,
    required this.noneOption,
    required this.selectedValues,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.8)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((disease) {
          final isNoneOption = disease == noneOption;
          final isSelected = selectedValues.contains(disease);
          return GestureDetector(
            onTap: () => onToggle(disease),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? scheme.primary : AppColors.inactiveSlider,
                borderRadius: BorderRadius.circular(14),
                border: isNoneOption
                    ? Border.all(
                        color: isSelected
                            ? scheme.primary.withOpacity(0.18)
                            : scheme.outlineVariant.withOpacity(0.75),
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isNoneOption) ...[
                    Icon(
                      Icons.block_rounded,
                      size: 16,
                      color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    disease,
                    style: TextStyle(
                      color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
