import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_colors.dart';

class MedicalFactorSliderCard extends StatelessWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged;

  const MedicalFactorSliderCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${value.toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 7,
              activeTrackColor: scheme.primary,
              inactiveTrackColor: AppColors.inactiveSlider,
              thumbColor: scheme.primary,
              overlayColor: Colors.transparent,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
