import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/responsive/page_scaffold.dart';
import 'package:lung_diagnosis_app/core/responsive/responsive_shell.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_confirmation_dialog.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/audio_preview_sheet.dart';
import 'package:lung_diagnosis_app/features/home/presentation/controllers/diagnosis_details_controller.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/diagnosis_details_actions.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/diagnosis_details_result_card.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/diagnosis_details_wave_card.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/diagnosis_details_xray_header.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DiagnosisDetailsScreen extends StatefulWidget {
  final DiagnosisKind kind;
  final DiagnosisItem item;
  final bool allowDelete;
  final String? ownerUserId;

  const DiagnosisDetailsScreen({
    super.key,
    required this.kind,
    required this.item,
    this.allowDelete = true,
    this.ownerUserId,
  });

  @override
  State<DiagnosisDetailsScreen> createState() => _DiagnosisDetailsScreenState();
}

class _DiagnosisDetailsScreenState extends State<DiagnosisDetailsScreen> {
  DiagnosisKind get kind => widget.kind;
  DiagnosisItem get item => widget.item;

  DiagnosisDetailsController _controller(BuildContext context) {
    return DiagnosisDetailsController(
      historyRepository: context.read<DiagnosisHistoryRepository>(),
      kind: kind,
      item: item,
      ownerUserId: widget.ownerUserId,
    );
  }

  Future<void> _deleteThisItem() async {
    final ok = await AppConfirmationDialog.show(
      context,
      title: 'Delete this result?',
      message:
          'This will remove it from history and delete its stored file from the device.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );

    if (!ok) return;

    await _controller(context).deleteItem();

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget _body(BuildContext context) {
    final viewData = _controller(context).buildViewData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DiagnosisDetailsXrayHeader(
            type: viewData.type,
            imagePath: item.imagePath,
          ),
          if (viewData.hasImage) const SizedBox(height: 14),
          DiagnosisDetailsResultCard(
            type: viewData.type,
            item: item,
            result: viewData.result,
            waveSection: DiagnosisDetailsWaveCard(
              hasAudio: viewData.hasAudio,
              item: item,
            ),
          ),
          if (!widget.allowDelete) ...[
            const SizedBox(height: 16),
            _ReadOnlyNoticeCard(
              kind: kind,
              ownerUserId: widget.ownerUserId,
            ),
          ],
          const SizedBox(height: 16),
          DiagnosisDetailsActions(
            // Hide the audio play button for history/API read-only results.
            // Keep it available only for local review before sending/analyzing.
            canPlay: widget.allowDelete && viewData.hasAudio,
            canDelete: widget.allowDelete,
            onPlayAudio: widget.allowDelete && viewData.hasAudio && viewData.audioPath != null
                ? () => AudioPreviewSheet.show(context, viewData.audioPath!)
                : null,
            onDelete: widget.allowDelete ? _deleteThisItem : null,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = _body(context);
    final wide = PageScaffold(maxWidth: 720, child: _body(context));

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.details,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ResponsiveShell(
          mobile: mobile,
          tablet: wide,
          desktop: wide,
        ),
      ),
    );
  }
}

class _ReadOnlyNoticeCard extends StatelessWidget {
  final DiagnosisKind kind;
  final String? ownerUserId;

  const _ReadOnlyNoticeCard({
    required this.kind,
    this.ownerUserId,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalizedOwnerUserId = (ownerUserId ?? '').trim();
    final bool isPatientOwnedView = normalizedOwnerUserId.isNotEmpty;
    final String title;
    final String message;

    if (!isPatientOwnedView) {
      final label = kind.isImaging ? 'X-ray' : 'audio';
      title = 'API history item';
      message =
          'This $label result is loaded from the API history, so delete is disabled here because there is no backend delete endpoint yet.';
    } else if (kind.isImaging) {
      title = 'Read-only patient result';
      message =
          'You are viewing this X-ray from a patient account, so edit and delete actions are hidden here.';
    } else {
      title = 'Read-only patient result';
      message =
          'This audio result belongs to a patient account, so delete actions are hidden here.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withOpacity(0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: scheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
