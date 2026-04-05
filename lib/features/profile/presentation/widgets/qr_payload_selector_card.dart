import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/models/qr_payload_type.dart';

class QrPayloadSelectorCard extends StatelessWidget {
  final QrPayloadType selectedType;
  final bool hasNationalId;
  final ValueChanged<QrPayloadType> onChanged;

  const QrPayloadSelectorCard({
    super.key,
    required this.selectedType,
    required this.hasNationalId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose what to generate',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text(QrPayloadType.accountId.label),
                  selected: selectedType == QrPayloadType.accountId,
                  onSelected: (_) => onChanged(QrPayloadType.accountId),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: Text(QrPayloadType.nationalId.label),
                  selected: selectedType == QrPayloadType.nationalId,
                  onSelected: (_) => onChanged(QrPayloadType.nationalId),
                ),
              ),
            ],
          ),
          if (selectedType == QrPayloadType.nationalId && !hasNationalId) ...[
            const SizedBox(height: 10),
            Text(
              'No National ID found for this account.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: scheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
