import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/logic/stethoscope_controller.dart';

class StethoscopeAudioPreviewHeader extends StatelessWidget {
  final String sourceLabel;
  final StethoscopeRecipient recipient;

  const StethoscopeAudioPreviewHeader({
    super.key,
    required this.sourceLabel,
    required this.recipient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.graphic_eq_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sourceLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                recipient == StethoscopeRecipient.doctor
                    ? 'Saved to your account after confirmation'
                    : 'Prepared to send to the selected patient',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
