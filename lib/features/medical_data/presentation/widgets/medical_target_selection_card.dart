import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_account_option.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_mode.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_target_preview_card.dart';

class MedicalTargetSelectionCard extends StatelessWidget {
  final MedicalTargetMode mode;
  final MedicalTargetAccountOption currentDoctor;
  final MedicalTargetAccountOption? selectedTarget;
  final ValueChanged<MedicalTargetMode> onModeChanged;
  final VoidCallback onPickTarget;
  final bool isLoadingTargetOptions;
  final String? targetLoadError;

  const MedicalTargetSelectionCard({
    super.key,
    required this.mode,
    required this.currentDoctor,
    required this.selectedTarget,
    required this.onModeChanged,
    required this.onPickTarget,
    this.isLoadingTargetOptions = false,
    this.targetLoadError,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasLoadError = (targetLoadError ?? '').trim().isNotEmpty;

    String previewTitle() {
      if (selectedTarget != null) return 'Selected recipient account';
      if (isLoadingTargetOptions) return 'Loading available accounts';
      if (mode == MedicalTargetMode.patient) return 'No patient selected yet';
      return 'No doctor selected yet';
    }

    String previewSubtitle() {
      if (selectedTarget != null) {
        return 'The form now represents the medical data stored for this account.';
      }
      if (isLoadingTargetOptions) {
        return 'Please wait while available accounts are loaded from the server.';
      }
      if (hasLoadError) {
        return 'Could not load available accounts. Retry, then choose the target account.';
      }
      return 'Select the target account first, then the form will load existing medical data if found.';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person_search_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose who will receive this medical data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The selected account will see these factors and diseases inside its dashboard and medical data page.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<MedicalTargetMode>(
            segments: const [
              ButtonSegment(value: MedicalTargetMode.me, label: Text('For me')),
              ButtonSegment(value: MedicalTargetMode.patient, label: Text('For patient')),
              ButtonSegment(value: MedicalTargetMode.doctor, label: Text('For doctor')),
            ],
            selected: {mode},
            onSelectionChanged: (selection) => onModeChanged(selection.first),
          ),
          const SizedBox(height: 14),
          if (mode == MedicalTargetMode.me)
            MedicalTargetPreviewCard(
              title: 'This medical data will be saved to your doctor account',
              subtitle: 'Choosing “For me” is already your confirmation.',
              icon: Icons.verified_user_rounded,
              name: currentDoctor.name,
              email: currentDoctor.email,
            )
          else ...[
            MedicalTargetPreviewCard(
              title: previewTitle(),
              subtitle: previewSubtitle(),
              icon: mode == MedicalTargetMode.patient
                  ? Icons.personal_injury_rounded
                  : Icons.medical_services_rounded,
              name: selectedTarget?.name,
              email: selectedTarget?.email,
              actionLabel: isLoadingTargetOptions
                  ? 'Loading accounts...'
                  : (selectedTarget == null ? 'Choose account' : 'Change account'),
              onAction: onPickTarget,
              isBusy: isLoadingTargetOptions,
            ),
            if (hasLoadError) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.error.withOpacity(0.18)),
                ),
                child: Text(
                  targetLoadError!,
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
