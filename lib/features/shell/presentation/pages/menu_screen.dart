import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/controllers/menu_screen_controller.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/helpers/menu_items_builder.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/menu_items_section.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/menu_profile_header_card.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  static const MenuScreenController _controller = MenuScreenController();

  final bool isDoctor;

  const MenuScreen({
    super.key,
    required this.isDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = buildMenuItems(context, isDoctor: isDoctor);
    final auth = context.watch<AuthController>();
    final profile = context.watch<ProfileController>().profile;
    final viewData = _controller.build(
      currentUserName: auth.currentUserName,
      currentUserEmail: auth.currentUser?.email,
      avatarPath: profile?.avatarPath,
    );

    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.menu,
        backgroundColor: Colors.transparent,
        elevation: 0,
        showBack: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          MenuProfileHeaderCard(
            name: viewData.name,
            email: viewData.email,
            avatarPath: viewData.avatarPath,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          const SizedBox(height: 18),
          MenuItemsSection(items: menuItems),
        ],
      ),
    );
  }
}
