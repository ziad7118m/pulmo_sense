import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/utils/date_text_formatter.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/medical_data/logic/medical_profile_controller.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_data_screen_view_data.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_mode.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/pages/add_medical_data_screen.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/pages/lung_risk_history_screen.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_data_empty_state.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_overall_risk_section.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_profile_factors_section.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_profile_hero_card.dart';
import 'package:provider/provider.dart';

class MedicalDataScreen extends StatefulWidget {
  const MedicalDataScreen({super.key});

  @override
  State<MedicalDataScreen> createState() => _MedicalDataScreenState();
}

class _MedicalDataScreenState extends State<MedicalDataScreen> {
  Future<void> _openEditor({
    MedicalTargetMode initialMode = MedicalTargetMode.me,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicalDataScreen(initialTargetMode: initialMode),
      ),
    );
    if (!mounted) return;
    await context.read<MedicalProfileController>().refreshCurrent();
  }

  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LungRiskHistoryScreen()),
    );
    if (!mounted) return;
    await context.read<MedicalProfileController>().refreshCurrent();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final medicalController = context.watch<MedicalProfileController>();
    final profile = medicalController.currentProfile;
    final viewData = MedicalDataScreenViewData(
      isDoctor: auth.isDoctor,
      isInitialLoading:
          medicalController.isLoading && auth.currentUser != null && profile == null,
      hasProfile: profile != null,
      profile: profile,
      updatedLabel: profile == null ? null : formatNumericDate(profile.updatedAt),
    );
    final canEditCurrent = auth.isDoctor && auth.currentUser != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.medicalData,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: viewData.isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : !viewData.hasProfile
              ? MedicalDataEmptyState(
                  canEdit: canEditCurrent,
                  onAddMedicalData: _openEditor,
                  onOpenHistory: _openHistory,
                )
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<MedicalProfileController>().refreshCurrent(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                MedicalProfileHeroCard(
                                  profile: viewData.profile!,
                                  factorsCount: viewData.profile!.factors.length,
                                  diseasesCount: viewData.profile!.diseases.length,
                                  updatedLabel: viewData.updatedLabel!,
                                ),
                                const SizedBox(height: 18),
                                MedicalOverallRiskSection(profile: viewData.profile!),
                                const SizedBox(height: 20),
                                MedicalProfileFactorsSection(
                                  factors: viewData.profile!.factors.entries.toList(),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    if (canEditCurrent)
                                      FilledButton.icon(
                                        onPressed: medicalController.isSaving
                                            ? null
                                            : () => _openEditor(),
                                        icon: const Icon(Icons.edit_rounded),
                                        label: const Text('Update lung risk factors'),
                                      ),
                                    OutlinedButton.icon(
                                      onPressed: _openHistory,
                                      icon: const Icon(Icons.history_rounded),
                                      label: const Text('Open risk history'),
                                    ),
                                  ],
                                ),
                              ],
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
