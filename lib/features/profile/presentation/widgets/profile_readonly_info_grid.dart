import 'package:flutter/material.dart';

class ProfileReadonlyInfoGrid extends StatelessWidget {
  final List<ProfileReadonlyInfoItem> items;

  const ProfileReadonlyInfoGrid({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < items.length; index++) ...[
          _ProfileReadonlyInfoRow(item: items[index]),
          if (index != items.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class ProfileReadonlyInfoItem {
  final String label;
  final String value;

  const ProfileReadonlyInfoItem({
    required this.label,
    required this.value,
  });
}

class _ProfileReadonlyInfoRow extends StatelessWidget {
  final ProfileReadonlyInfoItem item;

  const _ProfileReadonlyInfoRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            item.value,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
