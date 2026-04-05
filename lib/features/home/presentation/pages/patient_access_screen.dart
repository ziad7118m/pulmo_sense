import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/controllers/patient_access_controller.dart';
import 'package:lung_diagnosis_app/features/home/presentation/models/resolved_patient_access.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/patient_access_form_section.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/patient_access_submit_button.dart';
import 'package:provider/provider.dart';

class PatientAccessScreen extends StatefulWidget {
  const PatientAccessScreen({super.key});

  @override
  State<PatientAccessScreen> createState() => _PatientAccessScreenState();
}

class _PatientAccessScreenState extends State<PatientAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<PatientAccessController>();
    final resolved = await controller.resolve(
      patientId: _patientIdController.text,
      nationalId: _nationalIdController.text,
    );

    if (!mounted || resolved == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(patientView: resolved.toPatientView()),
      ),
    );
  }

  Future<void> _retryLookup() async {
    FocusScope.of(context).unfocus();
    await context.read<PatientAccessController>().retryLastLookup();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Consumer<PatientAccessController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: CustomAppBar(
            title: AppStrings.patientAccess,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PatientAccessHeroCard(
                      onClear: () {
                        _patientIdController.clear();
                        _nationalIdController.clear();
                        controller.clear();
                      },
                    ),
                    const SizedBox(height: 18),
                    PatientAccessFormSection(
                      patientIdController: _patientIdController,
                      nationalIdController: _nationalIdController,
                    ),
                    if (controller.lookupMessage != null) ...[
                      const SizedBox(height: 14),
                      _PatientAccessFeedbackCard(
                        message: controller.lookupMessage!,
                        isError: controller.isLookupFailure,
                        onRetry: controller.isLookupFailure && controller.canRetryLastLookup
                            ? _retryLookup
                            : null,
                      ),
                    ],
                    if (controller.lastResolvedPatient != null) ...[
                      const SizedBox(height: 14),
                      _PatientResolvedPreviewCard(
                        patient: controller.lastResolvedPatient!,
                      ),
                    ],
                    const SizedBox(height: 20),
                    PatientAccessSubmitButton(
                      isLoading: controller.isLoading,
                      onPressed: _continue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tip: using both fields reduces mismatches when more than one patient has similar details saved locally.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    context.read<PatientAccessController>().clear();
    _patientIdController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }
}

class _PatientAccessHeroCard extends StatelessWidget {
  final VoidCallback onClear;

  const _PatientAccessHeroCard({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withOpacity(0.96),
            scheme.primary.withOpacity(0.76),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.22),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person_search_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Find a patient and open the right dashboard directly.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We will search approved patient accounts using the details you enter, then open a read-only patient dashboard with their latest saved data.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientAccessFeedbackCard extends StatelessWidget {
  final String message;
  final bool isError;
  final Future<void> Function()? onRetry;

  const _PatientAccessFeedbackCard({
    required this.message,
    required this.isError,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = isError ? scheme.error : scheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => onRetry!.call(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: TextButton.styleFrom(
                      foregroundColor: accent,
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 0),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientResolvedPreviewCard extends StatelessWidget {
  final ResolvedPatientAccess patient;

  const _PatientResolvedPreviewCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.36),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primary.withOpacity(0.12),
                child: Text(
                  patient.firstName.characters.first.toUpperCase(),
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      patient.email.isEmpty ? 'No email saved' : patient.email,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  patient.matchedBy,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PreviewMetaChip(
                label: 'Patient ID',
                value: patient.userId,
              ),
              _PreviewMetaChip(
                label: 'National ID',
                value: patient.nationalId.isEmpty ? '-' : patient.nationalId,
              ),
              _PreviewMetaChip(
                label: 'Gender',
                value: patient.gender.isEmpty ? '-' : patient.gender,
              ),
              _PreviewMetaChip(
                label: 'Marital',
                value: patient.marital.isEmpty ? '-' : patient.marital,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewMetaChip extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewMetaChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
