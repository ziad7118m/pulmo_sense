import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_analyze_button.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_empty_state.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_source_actions_card.dart';

class StethoscopeAudioFlowSection extends StatelessWidget {
  final bool isRecording;
  final bool showEmptyState;
  final bool canShowPostAudioActions;
  final VoidCallback onRecord;
  final VoidCallback onUpload;
  final Widget? recordingPreview;
  final Widget? audioPreview;
  final VoidCallback onAnalyze;

  const StethoscopeAudioFlowSection({
    super.key,
    required this.isRecording,
    required this.showEmptyState,
    required this.canShowPostAudioActions,
    required this.onRecord,
    required this.onUpload,
    required this.recordingPreview,
    required this.audioPreview,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showEmptyState) const StethoscopeEmptyState(),
        StethoscopeSourceActionsCard(
          isRecording: isRecording,
          onRecord: onRecord,
          onUpload: onUpload,
        ),
        const SizedBox(height: 22),
        if (recordingPreview != null) recordingPreview!,
        if (audioPreview != null) audioPreview!,
        if (canShowPostAudioActions) ...[
          const SizedBox(height: 14),
          StethoscopeAnalyzeButton(onPressed: onAnalyze),
        ],
      ],
    );
  }
}
