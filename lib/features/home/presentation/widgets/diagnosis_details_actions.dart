import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_colors.dart';

class DiagnosisDetailsActions extends StatelessWidget {
  final bool canPlay;
  final bool canDelete;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onDelete;

  const DiagnosisDetailsActions({
    super.key,
    required this.canPlay,
    this.canDelete = true,
    this.onPlayAudio,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (!canPlay && !canDelete) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canPlay)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onPlayAudio,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: const Text(
                'Play audio',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          if (canPlay && canDelete) const SizedBox(height: 12),
          if (canDelete)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: BorderSide(color: AppColors.red.withOpacity(0.55)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text(
                'Delete from history',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }
}
