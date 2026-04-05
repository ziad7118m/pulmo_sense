import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_patient_view.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_latest_diagnosis_section.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_learn_more_section.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_medical_profile_section.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/risk_card_dashboard.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/pages/record_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/pages/stethoscope_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/pages/xray_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/details_screen.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_mode.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/pages/about_disease_info_screen.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/pages/add_medical_data_screen.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/pages/medical_data_screen.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/user_info_card.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DashboardScreen extends StatefulWidget {
  final DashboardPatientView? patientView;

  const DashboardScreen({super.key, this.patientView});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<MedicalProfileRecord?>? _medicalFuture;
  String? _medicalOwnerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reloadMedicalIfNeeded(force: false);
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientView?.userId != widget.patientView?.userId) {
      _reloadMedicalIfNeeded(force: true);
    }
  }

  void _reloadMedicalIfNeeded({required bool force}) {
    final auth = context.read<AuthController>();
    final ownerId = context.read<DashboardController>().resolveOwnerId(
      currentUser: auth.currentUser,
      patientView: widget.patientView,
    );
    if (!force && _medicalFuture != null && _medicalOwnerId == ownerId) {
      return;
    }
    _medicalOwnerId = ownerId;
    _medicalFuture = context.read<DashboardController>().loadMedicalProfile(ownerId);
  }

  Future<void> _pushAndRefresh(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    setState(() {
      _reloadMedicalIfNeeded(force: true);
    });
  }

  void _openDiagnosisDetails(DiagnosisKind kind, DiagnosisItem item) {
    _pushAndRefresh(
      DiagnosisDetailsScreen(
        kind: kind,
        item: item,
        allowDelete: widget.patientView == null,
        ownerUserId: widget.patientView?.userId,
      ),
    );
  }

  void _handlePatientStethoscopeTap(bool isDoctor) {
    if (widget.patientView != null) return;

    if (isDoctor) {
      _pushAndRefresh(const StethoscopeScreen(isDoctor: true));
      return;
    }

    AppTopMessage.error(
      context,
      'No stethoscope recording yet. Please visit a doctor with the stethoscope device to record and send it to your account.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = context.watch<ProfileController>().profile;
    final controller = context.read<DashboardController>();
    final viewData = controller.build(
      currentUser: auth.currentUser,
      currentProfile: profile,
      patientView: widget.patientView,
    );

    if (_medicalOwnerId != viewData.ownerId || _medicalFuture == null) {
      _medicalOwnerId = viewData.ownerId;
      _medicalFuture = controller.loadMedicalProfile(viewData.ownerId);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.patientView == null ? AppStrings.dashboard : 'Patient Dashboard',
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<MedicalProfileRecord?>(
        future: _medicalFuture,
        builder: (context, snapshot) {
          final medical = snapshot.data;
          final overallRisk = controller.resolveOverallRisk(medical);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (widget.patientView != null) ...[
                        _ViewedPatientBanner(view: widget.patientView!),
                        const SizedBox(height: 14),
                      ],
                      UserInfoCard(
                        userData: viewData.userData,
                        onTap: widget.patientView == null
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DashboardMedicalProfileSection(
                        medical: medical,
                        isDoctor: viewData.ownerIsDoctor,
                        isReadOnly: viewData.isReadOnly,
                        updatedLabel: medical == null ? null : 'Updated ${_relativeDate(medical.updatedAt)}',
                        onAddMedicalData: viewData.ownerIsDoctor && !viewData.isReadOnly
                            ? () => _pushAndRefresh(
                                  const AddMedicalDataScreen(
                                    initialTargetMode: MedicalTargetMode.me,
                                  ),
                                )
                            : null,
                        onOpenMedicalData: viewData.isReadOnly
                            ? null
                            : () => _pushAndRefresh(const MedicalDataScreen()),
                      ),
                      const SizedBox(height: 18),
                      DashboardLatestDiagnosisSection(
                        latestDiagnosis: viewData.latestDiagnosis,
                        isDoctor: viewData.ownerIsDoctor,
                        isReadOnly: viewData.isReadOnly,
                        onStartRecord: viewData.isReadOnly
                            ? null
                            : () => _pushAndRefresh(RecordScreen(isDoctor: viewData.ownerIsDoctor)),
                        onStartXray: viewData.isReadOnly
                            ? null
                            : () => _pushAndRefresh(XRayScreen(isDoctor: viewData.ownerIsDoctor)),
                        onStartStethoscope: viewData.isReadOnly
                            ? null
                            : () => _handlePatientStethoscopeTap(viewData.ownerIsDoctor),
                        onOpenRecordDetails: viewData.latestDiagnosis.latestRecord == null
                            ? null
                            : () => _openDiagnosisDetails(
                                  DiagnosisKind.record,
                                  viewData.latestDiagnosis.latestRecord!,
                                ),
                        onOpenXrayDetails: viewData.latestDiagnosis.latestXray == null
                            ? null
                            : () => _openDiagnosisDetails(
                                  DiagnosisKind.xray,
                                  viewData.latestDiagnosis.latestXray!,
                                ),
                        onOpenStethoscopeDetails: viewData.latestDiagnosis.latestStethoscope == null
                            ? null
                            : () => _openDiagnosisDetails(
                                  DiagnosisKind.stethoscope,
                                  viewData.latestDiagnosis.latestStethoscope!,
                                ),
                      ),
                      const SizedBox(height: 18),
                      DashboardSectionHeader(
                        icon: Icons.health_and_safety_rounded,
                        title: 'Risk',
                        subtitle: widget.patientView == null
                            ? 'Your overall risk summary at a glance.'
                            : 'Risk summary based on the patient medical factors saved so far.',
                      ),
                      const SizedBox(height: 12),
                      RiskDashboardCard(percentage: overallRisk),
                      const SizedBox(height: 12),
                      DashboardLearnMoreSection(
                        title: AppStrings.aboutCardTitle,
                        description: AppStrings.aboutCardDescription,
                        tipMessage: widget.patientView == null
                            ? 'Tip: record in a quiet place for the most accurate audio results.'
                            : 'Tip: ask the patient to keep previous reports available so the next review is easier.',
                        onOpenAbout: () => _pushAndRefresh(
                          AboutDiseaseInfoScreen(
                            title: AppStrings.aboutCardTitle,
                            description: AppStrings.aboutCardDescription,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ViewedPatientBanner extends StatelessWidget {
  final DashboardPatientView view;

  const _ViewedPatientBanner({required this.view});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.36),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.personal_injury_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Viewing patient mode',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${view.fullName} • National ID: ${view.nationalId}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _relativeDate(DateTime value) {
  final difference = DateTime.now().difference(value);
  if (difference.inDays >= 1) return '${difference.inDays}d ago';
  if (difference.inHours >= 1) return '${difference.inHours}h ago';
  if (difference.inMinutes >= 1) return '${difference.inMinutes}m ago';
  return 'just now';
}
