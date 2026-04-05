import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';

class RecordAnalyzeSection extends StatelessWidget {
  final bool canAnalyze;
  final VoidCallback onAnalyze;

  const RecordAnalyzeSection({
    super.key,
    required this.canAnalyze,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        IgnorePointer(
          ignoring: !canAnalyze,
          child: Opacity(
            opacity: canAnalyze ? 1.0 : 0.55,
            child: CustomButton(
              text: AppStrings.analyze,
              width: double.infinity,
              onPressed: onAnalyze,
            ),
          ),
        ),
        if (!canAnalyze) ...[
          const SizedBox(height: 10),
          Text(
            'Record an audio first to enable analysis.',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
