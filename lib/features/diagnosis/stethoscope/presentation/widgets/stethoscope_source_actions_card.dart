import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

class StethoscopeSourceActionsCard extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onRecord;
  final VoidCallback onUpload;

  const StethoscopeSourceActionsCard({
    super.key,
    required this.isRecording,
    required this.onRecord,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.78)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: isRecording ? 'Stop recording' : AppStrings.recordBtn,
              icon: isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              backgroundColor:
                  isRecording ? const Color(0xFFE53935) : scheme.primary,
              foregroundColor: Colors.white,
              onTap: onRecord,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: AppStrings.upload,
              icon: Icons.upload_rounded,
              backgroundColor: scheme.surfaceVariant.withOpacity(0.56),
              foregroundColor: scheme.onSurface,
              borderColor: scheme.outlineVariant.withOpacity(0.85),
              onTap: onUpload,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: borderColor == null ? null : Border.all(color: borderColor!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 22),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
