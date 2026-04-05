import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/responsive/page_scaffold.dart';
import 'package:lung_diagnosis_app/core/responsive/responsive_shell.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/add_article_screen.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/articles_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/home/presentation/controllers/home_doctor_controller.dart';
import 'package:lung_diagnosis_app/features/home/presentation/models/home_doctor_view_data.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/doctor_home_actions_row.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/doctor_home_post_box.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/home_articles_feed_section.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/home_profile_banner.dart';
import 'package:lung_diagnosis_app/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:provider/provider.dart';

class HomeDoctor extends StatelessWidget {
  final Function(int)? onTabChange;

  const HomeDoctor({
    super.key,
    this.onTabChange,
  });

  static const HomeDoctorController _controller = HomeDoctorController();

  void _openAddArticle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddArticleScreen()),
    );
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

  Widget _buildBanner(BuildContext context, HomeDoctorViewData viewData) {
    return HomeProfileBanner(
      firstName: viewData.doctorName,
      isDoctor: true,
      notificationCount: viewData.notificationCount,
      onNotificationTap: () => _openNotifications(context),
    );
  }

  Widget _buildActions(BuildContext context) {
    return DoctorHomeActionsRow(
      onTabChange: onTabChange == null ? null : (index) => onTabChange!(index),
    );
  }

  Widget _buildPostBox(BuildContext context, HomeDoctorViewData viewData) {
    return DoctorHomePostBox(
      profileImagePath: viewData.profileImagePath,
      onTap: () => _openAddArticle(context),
    );
  }

  Widget _buildArticlesSection(BuildContext context) {
    return HomeArticlesFeedSection(
      onSeeAll: () => _openArticles(context),
    );
  }

  Widget _mobile(BuildContext context, HomeDoctorViewData viewData) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBanner(context, viewData),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActions(context),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPostBox(context, viewData),
          ),
          const SizedBox(height: 8),
          _buildArticlesSection(context),
        ],
      ),
    );
  }

  Widget _tablet(BuildContext context, HomeDoctorViewData viewData) {
    return PageScaffold(
      maxWidth: 1100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildBanner(context, viewData),
                const SizedBox(height: 18),
                _buildActions(context),
                const SizedBox(height: 24),
                _buildPostBox(context, viewData),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildArticlesSection(context),
          ),
        ],
      ),
    );
  }

  Widget _desktop(BuildContext context, HomeDoctorViewData viewData) {
    return PageScaffold(
      maxWidth: 1300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildBanner(context, viewData),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildActions(context),
                const SizedBox(height: 24),
                _buildPostBox(context, viewData),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildArticlesSection(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = context.watch<ProfileController>().profile;
    final viewData = _controller.build(
      currentUserName: auth.currentUserName,
      avatarPath: profile?.avatarPath,
      notificationCount: NotificationsScreen.mockNotifications.length,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ResponsiveShell(
        mobile: _mobile(context, viewData),
        tablet: _tablet(context, viewData),
        desktop: _desktop(context, viewData),
      ),
    );
  }
}
