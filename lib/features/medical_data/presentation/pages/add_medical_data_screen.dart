import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/errors/error_mapper.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/medical_data/logic/medical_profile_controller.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/controllers/add_medical_data_controller.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_mode.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_factor_sliders_section.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_save_profile_bar.dart';
import 'package:provider/provider.dart';

class AddMedicalDataScreen extends StatefulWidget {
  final MedicalTargetMode initialTargetMode;

  const AddMedicalDataScreen({
    super.key,
    this.initialTargetMode = MedicalTargetMode.me,
  });

  @override
  State<AddMedicalDataScreen> createState() => _AddMedicalDataScreenState();
}

class _AddMedicalDataScreenState extends State<AddMedicalDataScreen> {
  final AddMedicalDataController _pageController = const AddMedicalDataController();

  late final Map<String, double> _factors = _pageController.createInitialFactors();
  final Set<String> _selectedDiseases = <String>{};
  bool _didLoadInitial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitial) return;
    _didLoadInitial = true;
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final current = context.read<AuthController>().currentUser;
    if (current == null) return;

    final existing = await context.read<MedicalProfileController>().loadOwnerProfile(current.id);
    if (!mounted) return;

    setState(() {
      _pageController.applyProfile(
        factors: _factors,
        selectedDiseases: _selectedDiseases,
        existing: existing,
      );
    });
  }

  Future<void> _save() async {
    final auth = context.read<AuthController>();
    final user = auth.currentUser;
    if (user == null) return;

    final validationMessage = _pageController.validate(
      currentDoctor: user,
      owner: user,
      mode: MedicalTargetMode.me,
      selectedDiseases: _selectedDiseases,
    );

    if (validationMessage != null) {
      AppTopMessage.error(context, validationMessage);
      return;
    }

    final profile = _pageController.buildProfile(
      owner: user,
      doctor: user,
      factors: _factors,
      selectedDiseases: _selectedDiseases,
    );

    final medicalController = context.read<MedicalProfileController>();

    try {
      await medicalController.saveProfile(
        profile,
        shouldRefreshCurrent: true,
      );
    } catch (error, stackTrace) {
      if (!mounted) return;
      AppTopMessage.error(context, ErrorMapper.map(error, stackTrace).message);
      return;
    }

    if (!mounted) return;
    AppTopMessage.success(context, AppStrings.saveSuccessMedical);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final currentUser = auth.currentUser;
    final isSaving = context.watch<MedicalProfileController>().isSaving;

    if (currentUser == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: AppStrings.addMedical,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: EmptyStateCard(
              icon: Icons.lock_outline_rounded,
              title: 'Session expired',
              message: 'Please log in again before updating your lung risk factors.',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.addMedical,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BackendMedicalNoticeCard(userName: currentUser.displayName),
                  const SizedBox(height: 18),
                  MedicalFactorSlidersSection(
                    factors: _factors,
                    onFactorChanged: (entry) {
                      setState(() => _factors[entry.key] = entry.value);
                    },
                  ),
                ],
              ),
            ),
            MedicalSaveProfileBar(
              label: _pageController.saveLabel(MedicalTargetMode.me),
              isSaving: isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _BackendMedicalNoticeCard extends StatelessWidget {
  final String userName;

  const _BackendMedicalNoticeCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Backend-connected lung risk factors',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'These values are saved to your account by calling the backend lung risk analyze endpoint. The latest saved run powers the medical data page, dashboard, and risk history for $userName.',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
