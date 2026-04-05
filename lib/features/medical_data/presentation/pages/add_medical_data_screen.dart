import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/medical_data/logic/medical_profile_controller.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/controllers/add_medical_data_controller.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_account_option.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_mode.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_diseases_section.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_factor_sliders_section.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_save_profile_bar.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_target_picker_sheet.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_target_selection_card.dart';
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

  MedicalTargetMode _mode = MedicalTargetMode.me;
  AuthUser? _selectedTarget;
  bool _didLoadInitial = false;
  bool _isLoadingTargets = false;
  String? _targetLoadError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitial) return;
    _didLoadInitial = true;
    _mode = widget.initialTargetMode;
    _loadCurrentTargetProfile();
  }

  Future<List<AuthUser>> _loadTargetCandidates(AuthController auth) async {
    auth.clearError();
    setState(() {
      _isLoadingTargets = true;
      _targetLoadError = null;
    });

    try {
      final users = _mode == MedicalTargetMode.patient
          ? await auth.fetchPatients()
          : await auth.fetchDoctors();

      if (!mounted) return users;

      setState(() {
        _isLoadingTargets = false;
        _targetLoadError = auth.error;
      });
      return users;
    } catch (error) {
      if (!mounted) return const <AuthUser>[];
      setState(() {
        _isLoadingTargets = false;
        _targetLoadError = error.toString();
      });
      return const <AuthUser>[];
    }
  }

  Future<void> _loadCurrentTargetProfile() async {
    final auth = context.read<AuthController>();
    final current = auth.currentUser;
    if (current == null) return;

    final owner = _pageController.resolveOwner(
      currentDoctor: current,
      mode: _mode,
      selectedTarget: _selectedTarget,
    );

    if (owner == null) {
      if (!mounted) return;
      setState(() {
        _pageController.resetForm(
          factors: _factors,
          selectedDiseases: _selectedDiseases,
        );
      });
      return;
    }

    final existing = await context.read<MedicalProfileController>().loadOwnerProfile(owner.id);
    if (!mounted) return;

    setState(() {
      _pageController.applyProfile(
        factors: _factors,
        selectedDiseases: _selectedDiseases,
        existing: existing,
      );
    });
  }

  Future<void> _pickTarget() async {
    final auth = context.read<AuthController>();
    final users = await _loadTargetCandidates(auth);

    if (!mounted) return;

    final loadError = _targetLoadError?.trim();
    if (loadError != null && loadError.isNotEmpty) {
      AppTopMessage.error(context, loadError);
      return;
    }

    final currentId = auth.currentUser?.id;
    final filtered = _pageController.filterSelectableUsers(
      users: users,
      currentUserId: currentId,
    );

    if (filtered.isEmpty) {
      AppTopMessage.error(context, _pageController.emptyAccountsMessage(_mode));
      return;
    }

    final options = _pageController.toTargetOptions(filtered);
    final picked = await showModalBottomSheet<MedicalTargetAccountOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => MedicalTargetPickerSheet(
        mode: _mode,
        users: options,
      ),
    );

    if (picked == null) return;
    final selected = filtered.cast<AuthUser?>().firstWhere(
          (user) => user?.id == picked.id,
          orElse: () => null,
        );
    if (selected == null) return;

    setState(() => _selectedTarget = selected);
    await _loadCurrentTargetProfile();
  }

  void _toggleDiseaseSelection(String disease) {
    setState(() {
      _pageController.toggleDisease(_selectedDiseases, disease);
    });
  }

  Future<void> _save() async {
    final auth = context.read<AuthController>();
    final doctor = auth.currentUser;
    if (doctor == null) return;

    final owner = _pageController.resolveOwner(
      currentDoctor: doctor,
      mode: _mode,
      selectedTarget: _selectedTarget,
    );

    final validationMessage = _pageController.validate(
      currentDoctor: doctor,
      owner: owner,
      mode: _mode,
      selectedDiseases: _selectedDiseases,
    );

    if (validationMessage != null) {
      AppTopMessage.error(context, validationMessage);
      return;
    }

    final profile = _pageController.buildProfile(
      owner: owner!,
      doctor: doctor,
      factors: _factors,
      selectedDiseases: _selectedDiseases,
    );

    final medicalController = context.read<MedicalProfileController>();
    await medicalController.saveProfile(
      profile,
      shouldRefreshCurrent: owner.id == doctor.id,
    );

    if (!mounted) return;
    AppTopMessage.success(context, AppStrings.saveSuccessMedical);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final doctor = auth.currentUser;
    final isSaving = context.watch<MedicalProfileController>().isSaving;
    final viewData = _pageController.buildViewData(
      currentDoctor: doctor,
      mode: _mode,
      selectedTarget: _selectedTarget,
      isSaving: isSaving,
      isLoadingTargets: _isLoadingTargets,
      targetLoadError: _targetLoadError,
    );

    if (!viewData.isDoctorEditor) {
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
              title: 'Medical data editing is doctor-only',
              message:
                  'Patients can view their medical data, but adding or editing it requires a doctor account.',
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
                  MedicalTargetSelectionCard(
                    mode: viewData.mode,
                    currentDoctor: viewData.currentDoctor!,
                    selectedTarget: viewData.selectedTarget,
                    onModeChanged: (mode) async {
                      setState(() {
                        _mode = mode;
                        _targetLoadError = null;
                        if (mode == MedicalTargetMode.me) {
                          _selectedTarget = null;
                        }
                      });
                      await _loadCurrentTargetProfile();
                    },
                    onPickTarget: viewData.mode == MedicalTargetMode.me
                        ? () {}
                        : () {
                            _pickTarget();
                          },
                    isLoadingTargetOptions: viewData.isLoadingTargets,
                    targetLoadError: viewData.targetLoadError,
                  ),
                  const SizedBox(height: 18),
                  MedicalFactorSlidersSection(
                    factors: _factors,
                    onFactorChanged: (entry) {
                      setState(() => _factors[entry.key] = entry.value);
                    },
                  ),
                  const SizedBox(height: 18),
                  MedicalDiseasesSection(
                    options: AddMedicalDataController.diseaseTitles,
                    noneOption: AddMedicalDataController.noDiseasesOption,
                    selectedValues: _selectedDiseases,
                    onToggle: _toggleDiseaseSelection,
                  ),
                ],
              ),
            ),
            MedicalSaveProfileBar(
              label: viewData.saveLabel,
              isSaving: viewData.isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
