import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/controllers/admin_user_details_page_controller.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_doctor_articles_section.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_empty_state.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_user_actions_section.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_user_details_header.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_user_info_card.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';

class AdminUserDetailsPage extends StatefulWidget {
  final AuthUser user;

  const AdminUserDetailsPage({super.key, required this.user});

  @override
  State<AdminUserDetailsPage> createState() => _AdminUserDetailsPageState();
}

class _AdminUserDetailsPageState extends State<AdminUserDetailsPage> {
  late final AdminUserDetailsPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminUserDetailsPageController(
      profileRepository: context.read<ProfileRepository>(),
      articleController: context.read<ArticleController>(),
    );
    _controller.load(widget.user);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading && !_controller.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.hasError && !_controller.hasData) {
            return AdminEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load user details',
              message: _controller.errorMessage!,
              actionLabel: 'Retry',
              onAction: _controller.retry,
            );
          }

          if (!_controller.hasData) {
            return AdminEmptyState(
              icon: Icons.person_off_rounded,
              title: 'No details available',
              message: 'This account does not have enough data to show the details screen yet.',
              actionLabel: 'Retry',
              onAction: _controller.retry,
            );
          }

          final data = _controller.data!;
          final profile = data.profile;
          return RefreshIndicator(
            onRefresh: _controller.retry,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_controller.hasError) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_controller.errorMessage!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                AdminUserDetailsHeader(user: user, profile: profile),
                const SizedBox(height: 16),
                AdminUserInfoCard(
                  title: 'Account overview',
                  subtitle: 'Identity, current role, and approval state.',
                  icon: Icons.badge_rounded,
                  rows: data.accountRows,
                ),
                const SizedBox(height: 16),
                AdminUserInfoCard(
                  title: 'Profile details',
                  subtitle: 'Locally stored profile data associated with this user.',
                  icon: Icons.contact_page_rounded,
                  rows: data.profileRows,
                ),
                const SizedBox(height: 16),
                AdminUserInfoCard(
                  title: 'Admin insights',
                  subtitle: 'Quick guidance before taking an action on this account.',
                  icon: Icons.insights_rounded,
                  rows: data.insightRows,
                ),
                const SizedBox(height: 16),
                AdminUserActionsSection(user: user),
                if (user.role.isDoctor) ...[
                  const SizedBox(height: 16),
                  AdminDoctorArticlesSection(doctorUserId: user.id),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
