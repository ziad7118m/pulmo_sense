import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_confirmation_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/responsive/page_scaffold.dart';
import 'package:lung_diagnosis_app/core/responsive/responsive_shell.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/logic/xray_controller.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/widgets/xray_image_preview_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/widgets/xray_instructions_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/helpers/diagnosis_meta_time.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/widgets/xray_upload_actions_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/widgets/xray_analyze_button.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/widgets/xray_sent_success_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/widgets/xray_upload_progress_card.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/details_screen.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_xray_usecase.dart';

class XRayScreen extends StatefulWidget {
  final bool isDoctor;

  const XRayScreen({super.key, required this.isDoctor});

  @override
  State<XRayScreen> createState() => _XRayScreenState();
}

class _XRayScreenState extends State<XRayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _resetPage(XRayController controller) async {
    await controller.resetSession();
    _fadeController.reset();
  }

  void _showAnalyzeConfirmation(
    BuildContext context,
    XRayController controller,
  ) async {
    if (!controller.canAnalyze) return;

    final ok = await AppConfirmationDialog.show(
      context,
      title: AppStrings.confirmImage,
      message: AppStrings.imageConfirmation,
      confirmLabel: AppStrings.ok,
      cancelLabel: AppStrings.cancel,
      icon: Icons.image_search_rounded,
    );

    if (!ok) return;
    final sent = await controller.analyzeXray();
    if (sent) controller.confirmImageSent();
  }

  Widget _buildSuccessCard(BuildContext context, XRayController controller) {
    return XraySentSuccessCard(
      timeLabel: formatDiagnosisMetaTime(controller.lastCompletedAt),
      onUploadAnother: () => _resetPage(controller),
      onViewResult: () {
        final latestItem = controller.latestHistoryItem;
        if (latestItem == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiagnosisDetailsScreen(
              kind: DiagnosisKind.xray,
              item: latestItem,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<XRayController>(
      builder: (context, controller, _) {
        final shouldShowEmpty = !controller.showSentCard &&
            !controller.isUploading &&
            controller.selectedImage == null;

        if (controller.errorMessage != null &&
            controller.errorMessage!.trim().isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            AppTopMessage.error(context, controller.errorMessage!);
            controller.clearError();
          });
        }

        if (!controller.isUploading && controller.selectedImage != null) {
          _fadeController.forward(from: 0);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => _resetPage(controller),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                  child: controller.showSentCard
                      ? Center(child: _buildSuccessCard(context, controller))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const XrayInstructionsCard(),
                            const SizedBox(height: 18),
                            XrayUploadActionsCard(
                              onPickGallery: () => controller.pickImage(ImageSource.gallery),
                              onPickCamera: () => controller.pickImage(ImageSource.camera),
                            ),
                            const SizedBox(height: 18),
                            if (shouldShowEmpty)
                              const EmptyStateCard(
                                icon: Icons.image_rounded,
                                title: 'No X-ray selected',
                                message: 'Pick an image from Gallery or take a photo, then analyze.',
                              ),
                            if (controller.isUploading)
                              XrayUploadProgressCard(progress: controller.progress),
                            if (!controller.isUploading &&
                                controller.selectedImage != null &&
                                !controller.showSentCard)
                              XrayImagePreviewCard(
                                imageFile: controller.selectedImage!,
                                fadeAnimation: _fadeAnimation,
                                onRemove: () {
                                  controller.removeImage();
                                  _fadeController.reset();
                                },
                              ),
                            if (!controller.isUploading &&
                                controller.selectedImage != null &&
                                !controller.showSentCard)
                              XrayAnalyzeButton(
                                onPressed: () =>
                                    _showAnalyzeConfirmation(context, controller),
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
    final appBarColor = Theme.of(context).scaffoldBackgroundColor;

    return ChangeNotifierProvider(
      create: (context) => XRayController(
        analyzeXray: context.read<AnalyzeXrayUseCase>(),
        historyRepo: context.read<DiagnosisHistoryRepository>(),
      )..init(),
      child: Builder(
        builder: (context) {
          final mobileBody = _buildContent(context);
          final wideBody = PageScaffold(
            maxWidth: 860,
            child: _buildContent(context),
          );

          return Scaffold(
            appBar: CustomAppBar(
              title: AppStrings.xrayTitle,
              backgroundColor: appBarColor,
              elevation: 0,
              showBack: false,
            ),
            body: SafeArea(
              child: ResponsiveShell(
                mobile: mobileBody,
                tablet: wideBody,
                desktop: wideBody,
              ),
            ),
          );
        },
      ),
    );
  }
}
