import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_confirmation_dialog.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/responsive/page_scaffold.dart';
import 'package:lung_diagnosis_app/core/responsive/responsive_shell.dart';
import 'package:lung_diagnosis_app/core/session/app_session.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/helpers/diagnosis_duration_formatter.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/helpers/diagnosis_meta_time.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/data/stethoscope_doctor_prefs.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/logic/stethoscope_controller.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/helpers/stethoscope_patient_resolver.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/models/stethoscope_patient_lookup_mode.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/models/stethoscope_target_mode.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/pages/scan_code_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_audio_flow_section.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_audio_preview_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_doctor_assignment_section.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_progress_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_recording_preview_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_success_view.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/details_screen.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_audio_usecase.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class StethoscopeScreen extends StatefulWidget {
  final bool isDoctor;

  const StethoscopeScreen({super.key, this.isDoctor = true});

  @override
  State<StethoscopeScreen> createState() => _StethoscopeScreenState();
}

class _StethoscopeScreenState extends State<StethoscopeScreen> {
  Timer? _timer;
  int _seconds = 0;

  List<AuthUser> _patients = const [];

  final TextEditingController _patientInputCtrl = TextEditingController();
  StethoscopePatientLookupMode _patientMode = StethoscopePatientLookupMode.account;
  String? _resolvedPatientId;
  String? _resolvedPatientName;
  String? _resolvedPatientAvatar;
  String? _inputError;
  bool _isLoadingPatients = false;
  String? _patientLoadError;

  StethoscopeTargetMode _doctorTarget = StethoscopeTargetMode.patient;

  late final StethoscopePatientResolver _patientResolver;

  static const int _maxSeconds = 15;

  final AudioPlayer _previewPlayer = AudioPlayer();
  Duration _previewDuration = Duration.zero;
  Duration _previewPosition = Duration.zero;
  bool _isPreviewPlaying = false;
  String? _loadedPreviewPath;

  @override
  void initState() {
    super.initState();
    _patientResolver = StethoscopePatientResolver(
      context.read<ProfileRepository>(),
    );

    _previewPlayer.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _previewDuration = d);
    });
    _previewPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _previewPosition = p);
    });
    _previewPlayer.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _isPreviewPlaying = s == PlayerState.playing);
    });

    _loadPatientsIfNeeded();
    _restoreLastSelectionIfAny();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _previewPlayer.dispose();
    _patientInputCtrl.dispose();
    super.dispose();
  }

  void _resetPreviewUiState() {
    if (!mounted) return;
    setState(() {
      _loadedPreviewPath = null;
      _previewDuration = Duration.zero;
      _previewPosition = Duration.zero;
      _isPreviewPlaying = false;
    });
  }

  Future<void> _removeSelectedAudioAndResetPreview(
    StethoscopeController controller,
  ) async {
    await controller.clearSelectedAudio(deleteFile: true);
    await _previewPlayer.stop();
    _resetPreviewUiState();
  }

  Future<bool> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Yes',
    String cancelLabel = 'Cancel',
  }) async {
    return AppConfirmationDialog.show(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: Icons.multitrack_audio_rounded,
    );
  }

  bool _requiresConfirmedPatient(BuildContext context) {
    if (!widget.isDoctor || !_doctorTarget.isPatient) return false;
    final patientId = _resolvedPatientId?.trim();
    if (patientId != null && patientId.isNotEmpty) return false;
    AppTopMessage.error(context, 'Please confirm the patient account first');
    return true;
  }

  void _handleDoctorTargetChanged(StethoscopeController controller, StethoscopeTargetMode value) {
    if (!mounted) return;
    setState(() => _doctorTarget = value);

    if (value.isDoctorSelf) {
      setState(() {
        _inputError = null;
        _resolvedPatientId = null;
        _resolvedPatientName = null;
        _resolvedPatientAvatar = null;
      });
      controller.setRecipient(StethoscopeRecipient.doctor);
      controller.setTargetPatient(null);
      return;
    }

    controller.setRecipient(StethoscopeRecipient.patient);
    final patientId = _resolvedPatientId?.trim();
    if (patientId == null || patientId.isEmpty) {
      controller.setTargetPatient(null);
      return;
    }
    controller.setTargetPatient(patientId, name: _resolvedPatientName);
  }

  void _handlePatientModeChanged(StethoscopePatientLookupMode mode) {
    if (!mounted) return;
    setState(() {
      _patientMode = mode;
      _resolvedPatientId = null;
      _resolvedPatientName = null;
      _resolvedPatientAvatar = null;
      _inputError = null;
      _patientLoadError = null;
    });
    context.read<StethoscopeController>().setTargetPatient(null);
  }

  Future<void> _handleScannedPatient() async {
    final raw = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const ScanCodeScreen()),
    );
    if (raw == null || raw.trim().isEmpty || !mounted) return;
    setState(() => _patientInputCtrl.text = raw.trim());
    await _resolveAndSelectPatient(showErrors: true);
  }

  Future<void> _handleAudioRemove(StethoscopeController controller) async {
    final shouldDelete = await _showConfirmationDialog(
      context: context,
      title: 'Delete audio?',
      message: 'Do you want to remove this audio selection?',
      confirmLabel: 'Delete',
    );
    if (!shouldDelete) return;
    await _removeSelectedAudioAndResetPreview(controller);
  }

  Future<void> _resetPageState(StethoscopeController c) async {
    await _previewPlayer.stop();
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _seconds = 0;
      _previewDuration = Duration.zero;
      _previewPosition = Duration.zero;
      _isPreviewPlaying = false;
      _loadedPreviewPath = null;
    });
    await c.resetSession();
  }

  Future<void> _restoreLastSelectionIfAny() async {
    if (!widget.isDoctor) return;
    final doctorId = context.read<AppSession>().userId;
    if (doctorId == null || doctorId.trim().isEmpty) return;

    final saved = await StethoscopeDoctorPrefs.load(doctorId);
    if (saved == null || !mounted) return;

    setState(() {
      _patientMode = StethoscopePatientLookupModeX.fromRaw(saved.mode);
      _patientInputCtrl.text = saved.rawValue;
    });

    await _resolveAndSelectPatient(showErrors: false);
  }

  Future<void> _loadPatientsIfNeeded() async {
    if (!widget.isDoctor) return;

    final auth = context.read<AuthController>();
    auth.clearError();
    if (mounted) {
      setState(() {
        _isLoadingPatients = true;
        _patientLoadError = null;
      });
    }

    try {
      final items = await auth.fetchPatients();
      if (!mounted) return;

      setState(() {
        _patients = items;
        _isLoadingPatients = false;
        _patientLoadError = auth.error;
      });

      if (_patientInputCtrl.text.trim().isNotEmpty && _resolvedPatientId == null) {
        await _resolveAndSelectPatient(showErrors: false);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingPatients = false;
        _patientLoadError = error.toString();
      });
    }
  }

  Future<void> _resolveAndSelectPatient({required bool showErrors}) async {
    if (!widget.isDoctor) return;

    final selection = await _patientResolver.resolve(
      rawInput: _patientInputCtrl.text,
      patientMode: _patientMode,
      patients: _patients,
    );

    if (!selection.hasPatient) {
      if (showErrors && mounted) {
        setState(() {
          _inputError = selection.errorMessage;
          _resolvedPatientId = null;
          _resolvedPatientName = null;
          _resolvedPatientAvatar = null;
        });
      }
      context.read<StethoscopeController>().setTargetPatient(null);
      return;
    }

    if (!mounted) return;

    setState(() {
      _inputError = null;
      _resolvedPatientId = selection.patientId;
      _resolvedPatientName = selection.patientName;
      _resolvedPatientAvatar = selection.avatarPath;
    });

    context.read<StethoscopeController>().setTargetPatient(
          selection.patientId,
          name: selection.patientName,
        );

    final doctorId = context.read<AppSession>().userId;
    if (doctorId != null && doctorId.trim().isNotEmpty) {
      await StethoscopeDoctorPrefs.save(
        doctorId: doctorId.trim(),
        mode: _patientMode.storageValue,
        rawValue: selection.queryValue,
        resolvedPatientId: selection.patientId!,
      );
    }
  }
  void _startTimer(StethoscopeController c) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      if (!c.isRecording) {
        _timer?.cancel();
        return;
      }

      setState(() => _seconds += 1);

      if (_seconds >= _maxSeconds) {
        await c.stopRecording();
        _timer?.cancel();
      }
    });
  }
  Future<void> _ensurePreviewLoaded(String path) async {
    if (_loadedPreviewPath == path) return;
    _loadedPreviewPath = path;
    _previewDuration = Duration.zero;
    _previewPosition = Duration.zero;
    _isPreviewPlaying = false;
    try {
      await _previewPlayer.stop();
      await _previewPlayer.setSource(DeviceFileSource(path));
      final duration = await _previewPlayer.getDuration();
      if (!mounted || duration == null) return;
      setState(() => _previewDuration = duration);
    } catch (_) {}
  }

  Future<void> _togglePreview(String path) async {
    final f = File(path);
    if (!f.existsSync()) return;
    await _ensurePreviewLoaded(path);
    if (_isPreviewPlaying) {
      await _previewPlayer.pause();
    } else {
      await _previewPlayer.resume();
    }
  }

  Widget? _buildRecordingPreview(StethoscopeController c) {
    if (!c.isRecording) return null;
    return StethoscopeRecordingPreviewCard(
      level: c.level,
      elapsedLabel: formatDiagnosisDurationSeconds(_seconds),
      maxDurationLabel: formatDiagnosisDurationSeconds(_maxSeconds),
    );
  }

  Widget? _buildAudioReadyPreview(StethoscopeController c) {
    final path = c.selectedAudioPath;
    if (path == null || c.isRecording) return null;
    if (_loadedPreviewPath != path) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ensurePreviewLoaded(path);
      });
    }
    return StethoscopeAudioPreviewCard(
      controller: c,
      previewDuration: _previewDuration,
      previewPosition: _previewPosition,
      isPreviewPlaying: _isPreviewPlaying,
      formatDuration: formatDiagnosisDuration,
      onSeek: (value) async {
        final path = c.selectedAudioPath;
        if (path == null) return;
        await _ensurePreviewLoaded(path);
        await _previewPlayer.seek(Duration(milliseconds: value.toInt()));
      },
      onTogglePreview: () {
        final path = c.selectedAudioPath;
        if (path == null) return;
        _togglePreview(path);
      },
      onRemove: () => _handleAudioRemove(c),
    );
  }

  Future<void> _pickAudio(StethoscopeController c) async {
    if (!widget.isDoctor || _requiresConfirmedPatient(context)) return;

    if (c.isRecording) {
      final shouldDiscardRecording = await _showConfirmationDialog(
        context: context,
        title: 'Stop recording?',
        message:
            'You are currently recording. Do you want to stop and discard it to upload a file instead?',
        confirmLabel: 'Yes, discard',
      );
      if (!shouldDiscardRecording) return;
      await _removeSelectedAudioAndResetPreview(c);
      if (!mounted) return;
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null) return;
    final path = result.files.single.path;
    if (path == null) return;

    if (c.selectedAudioPath != null) {
      final shouldReplaceAudio = await _showConfirmationDialog(
        context: context,
        title: 'Replace audio?',
        message: c.sourceType == AudioSourceType.recorded
            ? 'A recorded audio is ready. Do you want to delete it and upload a file instead?'
            : 'An audio file is already selected. Do you want to replace it with another file?',
        confirmLabel: 'Yes, replace',
      );
      if (!shouldReplaceAudio) return;
      await _removeSelectedAudioAndResetPreview(c);
    }

    setState(() => _seconds = 0);
    c.setUploadedAudio(path);
  }

  Future<void> _handleRecordTap(StethoscopeController c) async {
    if (!widget.isDoctor || _requiresConfirmedPatient(context)) return;

    if (c.isRecording) {
      await c.stopRecording();
      _timer?.cancel();
      return;
    }

    if (c.selectedAudioPath != null) {
      final shouldReplaceAudio = await _showConfirmationDialog(
        context: context,
        title: 'Replace audio?',
        message: c.sourceType == AudioSourceType.uploaded
            ? 'An audio file is ready. Do you want to delete it and start recording instead?'
            : 'A recorded audio is already ready. Do you want to delete it and record again?',
        confirmLabel: 'Yes, replace',
      );
      if (!shouldReplaceAudio) return;
      await _removeSelectedAudioAndResetPreview(c);
    }

    setState(() => _seconds = 0);
    await c.startRecording();
    _startTimer(c);
  }

  Future<void> _handleAnalyzePressed(StethoscopeController c) async {
    if (!c.canAnalyze) return;

    if (_doctorTarget.isDoctorSelf) {
      c.setRecipient(StethoscopeRecipient.doctor);
      c.setTargetPatient(null);
    } else {
      final pid = _resolvedPatientId?.trim();
      if (pid == null || pid.isEmpty) {
        AppTopMessage.error(context, 'Please confirm the patient account first');
        return;
      }
      c.setRecipient(StethoscopeRecipient.patient);
      c.setTargetPatient(pid, name: _resolvedPatientName);
    }

    await _confirmAndSend(c);
  }

  Future<void> _confirmAndSend(StethoscopeController c) async {
    if (!c.canAnalyze) return;

    if (_doctorTarget.isDoctorSelf) {
      c.setRecipient(StethoscopeRecipient.doctor);
      c.setTargetPatient(null);
      c.analyzeStethoscope().then((ok) {
        if (!context.mounted || !ok) return;
        c.confirmSent();
      });
      return;
    }

    final pid = _resolvedPatientId?.trim();
    if (pid == null || pid.isEmpty) {
      AppTopMessage.error(context, 'Please confirm the patient account first');
      return;
    }

    c.setRecipient(StethoscopeRecipient.patient);
    c.setTargetPatient(pid, name: _resolvedPatientName);

    final ok = await AppConfirmationDialog.show(
      context,
      title: AppStrings.confirmAudio,
      message: AppStrings.confirmStethoscopeAsk,
      confirmLabel: AppStrings.ok,
      cancelLabel: AppStrings.cancel,
      icon: Icons.multitrack_audio_rounded,
    );
    if (!ok) return;
    final sent = await c.analyzeStethoscope();
    if (sent) c.confirmSent();
  }

  Widget _buildSlimProgressBar(StethoscopeController c) {
    return StethoscopeProgressCard(progress: c.progress);
  }

  Widget _buildSuccessState(StethoscopeController c) {
    return StethoscopeSuccessView(
      isForDoctor: c.recipient == StethoscopeRecipient.doctor,
      targetLabel: c.recipient == StethoscopeRecipient.doctor
          ? 'Saved to your account'
          : 'Sent to ${c.targetPatientName ?? 'selected patient'}',
      timeLabel: formatDiagnosisMetaTime(c.lastCompletedAt),
      onRecordAnother: () {
        _resetPageState(c);
      },
      onViewResult: () {
        final latestItem = c.latestHistoryItem;
        if (latestItem == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiagnosisDetailsScreen(
              kind: DiagnosisKind.stethoscope,
              item: latestItem,
              ownerUserId: ((latestItem.targetPatientId ?? '').trim().isEmpty)
                  ? null
                  : latestItem.targetPatientId,
              allowDelete: false,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(StethoscopeController c) {
    final shouldShowEmpty =
        !c.showSentCard && !c.isUploading && c.selectedAudioPath == null && !c.isRecording;
    final canShowPostAudioActions =
        !c.isUploading && !c.showSentCard && !c.isRecording && c.selectedAudioPath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        const SizedBox(height: 14),
        StethoscopeDoctorAssignmentSection(
          isDoctor: widget.isDoctor,
          doctorTarget: _doctorTarget,
          onDoctorTargetChanged: (value) => _handleDoctorTargetChanged(c, value),
          patientMode: _patientMode,
          patientController: _patientInputCtrl,
          errorText: _inputError,
          resolvedName: _resolvedPatientName,
          resolvedId: _resolvedPatientId,
          resolvedAvatarPath: _resolvedPatientAvatar,
          onPatientModeChanged: _handlePatientModeChanged,
          onScan: () {
            _handleScannedPatient();
          },
          onConfirm: () {
            _resolveAndSelectPatient(showErrors: true);
          },
          isLoadingPatients: _isLoadingPatients,
          patientLoadError: _patientLoadError,
          onRetryLoadPatients: _loadPatientsIfNeeded,
        ),
        if (c.isUploading) _buildSlimProgressBar(c),
        if (c.isUploading) const SizedBox(height: 8),
        if (!c.showSentCard)
          StethoscopeAudioFlowSection(
            isRecording: c.isRecording,
            showEmptyState: shouldShowEmpty,
            canShowPostAudioActions: canShowPostAudioActions,
            onRecord: () {
              _handleRecordTap(c);
            },
            onUpload: () {
              _pickAudio(c);
            },
            recordingPreview: _buildRecordingPreview(c),
            audioPreview: _buildAudioReadyPreview(c),
            onAnalyze: () {
              _handleAnalyzePressed(c);
            },
          ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return Consumer<StethoscopeController>(
      builder: (context, c, _) {
        if (c.errorMessage != null && c.errorMessage!.trim().isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            AppTopMessage.error(context, c.errorMessage!);
            c.clearError();
          });
        }

        if (c.successMessage != null && c.successMessage!.trim().isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            AppTopMessage.success(context, c.successMessage!);
            c.clearSuccess();
          });
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => _resetPageState(c),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                  child: c.showSentCard ? _buildSuccessState(c) : _buildMainContent(c),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StethoscopeController(
        analyzeAudio: context.read<AnalyzeAudioUseCase>(),
        historyRepo: context.read<DiagnosisHistoryRepository>(),
        session: context.read<AppSession>(),
      ),
      child: Builder(
        builder: (context) {
          final body = _content(context);

          return Scaffold(
            appBar: CustomAppBar(
              title: AppStrings.stethoscopeTitle,
              backgroundColor: Colors.transparent,
              elevation: 0,
              showBack: false,
              actions: null,
            ),
            body: SafeArea(
              child: ResponsiveShell(
                mobile: body,
                tablet: PageScaffold(maxWidth: 720, child: body),
                desktop: PageScaffold(maxWidth: 720, child: body),
              ),
            ),
          );
        },
      ),
    );
  }
}
