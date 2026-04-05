import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/helpers/profile_info_items_builder.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/models/profile_screen_view_data.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/profile_edit_button_section.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/profile_readonly_info_grid.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/profile_section_card.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';
import 'package:provider/provider.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _openEditor() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
    if (!mounted) return;
    await context.read<ProfileController>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profileController = context.watch<ProfileController>();
    final viewData = profileController.buildScreenViewData(auth.currentUser);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.profile,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: viewData == null
          ? const Center(child: Text('No user'))
          : viewData.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => context.read<ProfileController>().refresh(),
                  child: _ProfileBody(
                    viewData: viewData,
                    onEditPressed: _openEditor,
                  ),
                ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final ProfileScreenViewData viewData;
  final VoidCallback onEditPressed;

  const _ProfileBody({
    required this.viewData,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final user = viewData.user;
    final profile = viewData.profile;
    final fullName = user.displayName.trim();
    final infoItems = buildProfileInfoItems(profile);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProfileHeaderCard(
          name: fullName.isEmpty ? 'User' : fullName,
          email: user.email,
          id: user.id,
          role: user.role.displayName,
          status: user.status.displayName,
          createdAt: user.createdAt,
          avatarPath: profile.avatarPath,
        ),
        const SizedBox(height: 18),
        ProfileSectionCard(
          child: ProfileReadonlyInfoGrid(items: infoItems),
        ),
        const SizedBox(height: 18),
        ProfileEditButtonSection(onPressed: onEditPressed),
      ],
    );
  }
}
