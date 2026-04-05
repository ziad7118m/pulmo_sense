import 'package:flutter/material.dart';

class MedicalTargetPreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? name;
  final String? email;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isBusy;

  const MedicalTargetPreviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.name,
    this.email,
    this.actionLabel,
    this.onAction,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((name ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              name!,
              style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w900, fontSize: 15),
            ),
            if ((email ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                email!,
                style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ],
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onAction,
              icon: isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.manage_accounts_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
