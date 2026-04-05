import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/models/stethoscope_patient_lookup_mode.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/doctor_patient_mode_selector.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/doctor_patient_resolved_card.dart';

class DoctorPatientPickerCard extends StatelessWidget {
  final StethoscopePatientLookupMode mode;
  final TextEditingController controller;
  final String? errorText;
  final String? resolvedName;
  final String? resolvedId;
  final String? resolvedAvatarPath;
  final ValueChanged<StethoscopePatientLookupMode> onModeChanged;
  final VoidCallback onScan;
  final VoidCallback onConfirm;
  final bool isLoadingPatients;
  final String? loadErrorText;
  final VoidCallback? onRetryLoad;

  const DoctorPatientPickerCard({
    super.key,
    required this.mode,
    required this.controller,
    required this.errorText,
    required this.resolvedName,
    required this.resolvedId,
    required this.resolvedAvatarPath,
    required this.onModeChanged,
    required this.onScan,
    required this.onConfirm,
    this.isLoadingPatients = false,
    this.loadErrorText,
    this.onRetryLoad,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasResolvedPatient = resolvedId != null && resolvedId!.trim().isNotEmpty;
    final hasLoadError = (loadErrorText ?? '').trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.78)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.badge_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient account',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Choose who should receive this stethoscope result.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DoctorPatientModeSelector(
            mode: mode,
            onModeChanged: onModeChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: !isLoadingPatients,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]')),
            ],
            decoration: InputDecoration(
              hintText: mode.isNationalId ? 'Enter National ID' : 'Enter Account ID',
              prefixIcon: Icon(
                mode.isNationalId
                    ? Icons.credit_card_rounded
                    : Icons.person_search_rounded,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: scheme.outlineVariant.withOpacity(0.72),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
              filled: true,
              fillColor: scheme.surfaceVariant.withOpacity(0.18),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoadingPatients ? null : onScan,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Scan'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: scheme.outlineVariant.withOpacity(0.92),
                    ),
                    backgroundColor: scheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isLoadingPatients ? null : onConfirm,
                  icon: isLoadingPatients
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(isLoadingPatients ? 'Loading...' : 'Confirm patient'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoadingPatients) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(999),
            ),
          ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loadErrorText!,
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (onRetryLoad != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: onRetryLoad,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry loading patients'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (hasResolvedPatient) ...[
            const SizedBox(height: 12),
            DoctorPatientResolvedCard(
              resolvedName: resolvedName,
              resolvedId: resolvedId!,
              resolvedAvatarPath: resolvedAvatarPath,
            ),
          ],
          if (errorText != null && errorText!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errorText!,
              style: TextStyle(
                color: scheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceVariant.withOpacity(0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'The stethoscope result will be saved under the selected patient account.',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
