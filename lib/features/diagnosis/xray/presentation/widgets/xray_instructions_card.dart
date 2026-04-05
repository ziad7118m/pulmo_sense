import 'package:flutter/material.dart';

class XrayInstructionsCard extends StatelessWidget {
  const XrayInstructionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Before uploading',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure the X-ray is clear and centered for better analysis accuracy.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          const _InstructionItem(
            icon: Icons.center_focus_strong_rounded,
            title: 'Keep the chest centered',
            subtitle: 'Avoid cropped edges and make the lung area clearly visible.',
          ),
          const SizedBox(height: 14),
          const _InstructionItem(
            icon: Icons.wb_sunny_outlined,
            title: 'Use a clean image',
            subtitle: 'Prefer well-lit images without glare, blur, or extra background clutter.',
          ),
          const SizedBox(height: 14),
          const _InstructionItem(
            icon: Icons.document_scanner_outlined,
            title: 'Upload one image only',
            subtitle: 'Choose the clearest X-ray so the analysis can focus on one scan.',
          ),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InstructionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
