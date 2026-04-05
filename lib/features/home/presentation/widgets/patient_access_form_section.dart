import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

class PatientAccessFormSection extends StatelessWidget {
  final TextEditingController patientIdController;
  final TextEditingController nationalIdController;

  const PatientAccessFormSection({
    super.key,
    required this.patientIdController,
    required this.nationalIdController,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.manage_search_rounded,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.enterPatientDetails,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search by patient ID, national ID, or use both for a safer match.',
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HintChip(icon: Icons.badge_outlined, label: 'Patient ID'),
              _HintChip(icon: Icons.credit_card_rounded, label: 'National ID'),
              _HintChip(icon: Icons.verified_user_outlined, label: 'Approved patient only'),
            ],
          ),
          const SizedBox(height: 18),
          PatientAccessTextField(
            controller: patientIdController,
            label: AppStrings.patientId,
            hintText: 'Enter the patient account ID',
            prefixIcon: Icons.fingerprint_rounded,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          PatientAccessTextField(
            controller: nationalIdController,
            label: AppStrings.nationalId,
            hintText: 'Enter the 14-digit national ID',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

class PatientAccessTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;

  const PatientAccessTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      style: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: scheme.primary.withOpacity(0.9)),
        filled: true,
        fillColor: scheme.surfaceVariant.withOpacity(0.22),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.82)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.65)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.65)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HintChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
