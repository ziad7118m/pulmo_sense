import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/models/qr_payload_type.dart';

class QrCodeValueCard extends StatelessWidget {
  final QrPayloadType payloadType;
  final String payload;
  final VoidCallback onCopy;

  const QrCodeValueCard({
    super.key,
    required this.payloadType,
    required this.payload,
    required this.onCopy,
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
          Text(
            payloadType.title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          SelectableText(
            payload,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded),
              label: const Text(
                'Copy',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
