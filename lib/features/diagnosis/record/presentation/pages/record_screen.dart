import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/responsive/page_scaffold.dart';
import 'package:lung_diagnosis_app/core/responsive/responsive_shell.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_confirmation_dialog.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/logic/record_controller.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/widgets/record_controls_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/widgets/record_empty_state_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/helpers/diagnosis_duration_formatter.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/helpers/diagnosis_meta_time.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/widgets/record_header_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/widgets/record_sent_success_card.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/details_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_record_usecase.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class RecordScreen extends StatefulWidget {
  final bool isDoctor;

  const RecordScreen({super.key, required this.isDoctor});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  static const int _maxSeconds = 15;

  Timer? _timer;
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  String? _loadedPreviewPath;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() => _duration = duration);
    });
    _player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _startTimer(RecordController controller) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      controller.tickSecond();

      if (controller.isRecording &&
          controller.recordingSeconds >= _maxSeconds) {
        controller.stopRecording().then((_) {
          _timer?.cancel();
        });
      }

      if (!controller.isRecording) {
        _timer?.cancel();
      }
    });
  }
  Future<void> _togglePlay(String path) async {
    final file = File(path);
    if (!file.existsSync()) return;

    if (_loadedPreviewPath != path) {
      await _player.stop();
      _loadedPreviewPath = path;
      _duration = Duration.zero;
      _position = Duration.zero;
    }

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(path));
    }
  }

  void _confirmAndSend(BuildContext context, RecordController controller) async {
    if (!controller.canAnalyze) return;

    final shouldSend = await AppConfirmationDialog.show(
      context,
      title: AppStrings.confirmationRecordAsk,
      message: AppStrings.confirmationRecordDescription,
      confirmLabel: AppStrings.ok,
      cancelLabel: AppStrings.cancel,
      icon: Icons.verified_rounded,
    );

    if (!shouldSend) return;

    final ok = await controller.analyzeRecord();
    if (ok) controller.confirmSent();
  }

  Future<void> _handleMicTap(
    BuildContext context,
    RecordController controller,
  ) async {
    if (controller.isRecording) {
      await controller.stopRecording();
      _timer?.cancel();
      return;
    }

    if (controller.isRecorded) {
      final shouldReplace = await AppConfirmationDialog.show(
        context,
        title: 'Replace recording?',
        message:
            'You already have a recorded audio. Do you want to delete it and record again?',
        confirmLabel: 'Yes, replace',
        cancelLabel: 'No',
        icon: Icons.autorenew_rounded,
        isDestructive: true,
      );

      if (!shouldReplace) return;
    }

    await _player.stop();
    setState(() {
      _loadedPreviewPath = null;
      _duration = Duration.zero;
      _position = Duration.zero;
    });

    await controller.startRecording();
    _startTimer(controller);
  }

  Future<void> _resetPage(RecordController controller) async {
    await _player.stop();
    _timer?.cancel();
    if (!mounted) return;

    setState(() {
      _loadedPreviewPath = null;
      _duration = Duration.zero;
      _position = Duration.zero;
      _isPlaying = false;
    });
    await controller.resetSession();
  }

  Widget _buildSentCard(BuildContext context, RecordController controller) {
    return RecordSentSuccessCard(
      timeLabel: formatDiagnosisMetaTime(controller.lastCompletedAt),
      onRecordAnother: () => _resetPage(controller),
      onViewResult: () {
        final latestItem = controller.latestHistoryItem;
        if (latestItem == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiagnosisDetailsScreen(
              kind: DiagnosisKind.record,
              item: latestItem,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<RecordController>(
      builder: (context, controller, _) {
        final shouldShowEmpty = !controller.showSentCard &&
            !controller.isRecording &&
            !controller.isRecorded;

        if (controller.errorMessage != null &&
            controller.errorMessage!.trim().isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            AppTopMessage.error(context, controller.errorMessage!);
            controller.clearError();
          });
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => _resetPage(controller),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                  child: controller.showSentCard
                      ? Center(child: _buildSentCard(context, controller))
                      : Column(
                          children: [
                            const RecordHeaderCard(),
                            const SizedBox(height: 14),
                            if (shouldShowEmpty) const RecordEmptyStateCard(),
                            RecordControlsCard(
                              isRecording: controller.isRecording,
                              isRecorded: controller.isRecorded,
                              canAnalyze: controller.canAnalyze,
                              isPlaying: _isPlaying,
                              recordingSeconds: controller.recordingSeconds,
                              maxSeconds: _maxSeconds,
                              level: controller.level,
                              waveSamples: controller.waveSamples,
                              position: _position,
                              duration: _duration,
                              onMicTap: () => _handleMicTap(context, controller),
                              onTogglePlay: () => _togglePlay(controller.audioPath!),
                              onAnalyze: () => _confirmAndSend(context, controller),
                              onSeek: (value) => _player.seek(
                                Duration(milliseconds: value.toInt()),
                              ),
                              formatDuration: formatDiagnosisDurationSeconds,
                              formatPlaybackDuration: formatDiagnosisDuration,
                            ),
                          ],
                        ),
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
      create: (context) => RecordController(
        analyzeRecord: context.read<AnalyzeRecordUseCase>(),
        historyRepo: context.read<DiagnosisHistoryRepository>(),
      ),
      child: Builder(
        builder: (context) {
          final body = _buildContent(context);

          return Scaffold(
            appBar: CustomAppBar(
              title: AppStrings.recordTitle,
              backgroundColor: Colors.transparent,
              elevation: 0,
              showBack: false,
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
