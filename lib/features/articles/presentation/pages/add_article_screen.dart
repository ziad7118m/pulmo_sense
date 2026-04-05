import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_confirmation_dialog.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/add_article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/models/add_article_view_data.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_access_message.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_compose_form.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_image_source_sheet.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_post_success_card.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';
import 'package:provider/provider.dart';

import 'my_articles_screen.dart';

class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _picker = ImagePicker();
  late final AddArticleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AddArticleController(
      articleController: context.read<ArticleController>(),
      authController: context.read<AuthController>(),
      profileController: context.read<ProfileController>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openImagePickerSheet() {
    showArticleImageSourceSheet(
      context: context,
      maxImages: _controller.maxImages,
      onPickFromGallery: _pickFromGallery,
      onPickFromCamera: _pickFromCamera,
    );
  }

  Future<void> _pickFromGallery() async {
    if (!_controller.canAddImages) {
      AppTopMessage.error(
        context,
        'You can add up to ${_controller.maxImages} images only.',
      );
      return;
    }

    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    final added = _controller.addImageFiles(
      picked.map((item) => File(item.path)),
    );

    if (!mounted) return;
    if (picked.length > added) {
      AppTopMessage.error(
        context,
        'Only $added images were added (max ${_controller.maxImages}).',
      );
    }
  }

  Future<void> _pickFromCamera() async {
    if (!_controller.canAddImages) {
      AppTopMessage.error(
        context,
        'You can add up to ${_controller.maxImages} images only.',
      );
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    _controller.addImageFile(File(picked.path));
  }

  Future<void> _showConfirmDialog() async {
    final validationError = _controller.validate();
    if (validationError != null) {
      AppTopMessage.error(context, validationError);
      return;
    }

    final ok = await AppConfirmationDialog.show(
      context,
      title: AppStrings.confirmPost,
      message: AppStrings.confirmationAsk,
      confirmLabel: AppStrings.ok,
      cancelLabel: AppStrings.cancel,
      icon: Icons.article_outlined,
    );

    if (!ok) return;

    final posted = await _controller.post();
    if (!mounted || posted) return;

    final errorMessage = _controller.errorMessage;
    if ((errorMessage ?? '').trim().isNotEmpty) {
      AppTopMessage.error(context, errorMessage!);
      _controller.clearError();
    }
  }

  void _viewMyArticles() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyArticlesScreen()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: AppStrings.addArticle,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildSuccessScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ArticlePostSuccessCard(onViewMyArticles: _viewMyArticles),
    );
  }

  Widget _buildDoctorOnlyMessage() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const ArticleAccessMessage(
        message: 'Only doctors can create medical articles.',
      ),
    );
  }

  Widget _buildComposerBody(AddArticleViewData data) {
    if (data.isPosting) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
      child: ArticleComposeForm(
        doctorName: data.doctorName,
        avatarPath: data.avatarPath,
        titleController: _controller.titleController,
        contentController: _controller.contentController,
        images: data.images,
        maxImages: data.maxImages,
        onAddImages: _openImagePickerSheet,
        onRemoveImageAt: _controller.removeImageAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final data = _controller.viewData;

        if (data.isPosted) return _buildSuccessScaffold();
        if (!data.isDoctor) return _buildDoctorOnlyMessage();

        return Scaffold(
          appBar: _buildAppBar(),
          bottomNavigationBar: data.isPosting
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: CustomButton(
                      text: AppStrings.post,
                      height: 50,
                      width: double.infinity,
                      onPressed: _showConfirmDialog,
                    ),
                  ),
                ),
          body: SafeArea(child: _buildComposerBody(data)),
        );
      },
    );
  }
}
