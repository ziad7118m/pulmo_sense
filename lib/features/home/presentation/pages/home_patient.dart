import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/articles_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/pages/record_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/pages/xray_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/controllers/home_patient_controller.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/details_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/home_articles_feed_section.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/home_profile_banner.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/patient_home_actions_row.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/patient_home_latest_exams_section.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/tip_card.dart';
import 'package:lung_diagnosis_app/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class HomePatient extends StatefulWidget {
  final Function(int)? onTabChange;

  const HomePatient({
    super.key,
    this.onTabChange,
  });

  @override
  State<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {
  bool _didTriggerInitialSync = false;
  String? _xraySyncedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didTriggerInitialSync) return;
    _didTriggerInitialSync = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncXrayHistory();
    });
  }

  Future<void> _syncXrayHistory({bool force = false}) async {
    final repository = context.read<DiagnosisHistoryRepository>();
    if (!repository.supportsRemoteSync(DiagnosisKind.xray)) {
      return;
    }

    final auth = context.read<AuthController>();
    final userId = (auth.currentUser?.id ?? '').trim();
    if (userId.isEmpty) {
      return;
    }

    if (!force && _xraySyncedUserId == userId) {
      return;
    }

    await repository.syncRemoteHistoryByKind(
      DiagnosisKind.xray,
      userId: userId,
    );
    _xraySyncedUserId = userId;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pushAndRefresh(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    await _syncXrayHistory(force: true);
    if (mounted) {
      setState(() {});
    }
  }

  void _openArticles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ArticlesScreen()),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openDetails(DiagnosisKind kind, DiagnosisItem item) {
    _pushAndRefresh(
      DiagnosisDetailsScreen(
        kind: kind,
        item: item,
        allowDelete: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final historyRepository = context.read<DiagnosisHistoryRepository>();
    final viewData = context.read<HomePatientController>().build(
      historyRepository: historyRepository,
      currentUser: authController.currentUser,
    );

    final currentUserId = (authController.currentUser?.id ?? '').trim();
    if (currentUserId.isNotEmpty && currentUserId != _xraySyncedUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncXrayHistory();
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeProfileBanner(
              firstName: viewData.patientName,
              isDoctor: false,
              notificationCount: NotificationsScreen.mockNotifications.length,
              onNotificationTap: () => _openNotifications(context),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PatientHomeActionsRow(onTabChange: widget.onTabChange),
                  const SizedBox(height: 24),
                  const TipCard(),
                  const SizedBox(height: 24),
                  PatientHomeLatestExamsSection(
                    latestDiagnosis: viewData.latestDiagnosis,
                    onStartRecord: () =>
                        _pushAndRefresh(const RecordScreen(isDoctor: false)),
                    onStartXray: () =>
                        _pushAndRefresh(const XRayScreen(isDoctor: false)),
                    onOpenRecordDetails: viewData.latestDiagnosis.latestRecord == null
                        ? null
                        : () => _openDetails(
                              DiagnosisKind.record,
                              viewData.latestDiagnosis.latestRecord!,
                            ),
                    onOpenXrayDetails: viewData.latestDiagnosis.latestXray == null
                        ? null
                        : () => _openDetails(
                              DiagnosisKind.xray,
                              viewData.latestDiagnosis.latestXray!,
                            ),
                    onOpenStethoscopeDetails:
                        viewData.latestDiagnosis.latestStethoscope == null
                            ? null
                            : () => _openDetails(
                                  DiagnosisKind.stethoscope,
                                  viewData.latestDiagnosis.latestStethoscope!,
                                ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            HomeArticlesFeedSection(
              onSeeAll: () => _openArticles(context),
            ),
          ],
        ),
      ),
    );
  }
}
