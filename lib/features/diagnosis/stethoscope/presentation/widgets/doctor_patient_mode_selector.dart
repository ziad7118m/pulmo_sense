import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/models/stethoscope_patient_lookup_mode.dart';

class DoctorPatientModeSelector extends StatelessWidget {
  final StethoscopePatientLookupMode mode;
  final ValueChanged<StethoscopePatientLookupMode> onModeChanged;

  const DoctorPatientModeSelector({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentTile(
              label: 'Account',
              selected: mode == StethoscopePatientLookupMode.account,
              onTap: () => onModeChanged(StethoscopePatientLookupMode.account),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SegmentTile(
              label: 'National ID',
              selected: mode == StethoscopePatientLookupMode.nationalId,
              onTap: () => onModeChanged(StethoscopePatientLookupMode.nationalId),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : scheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
