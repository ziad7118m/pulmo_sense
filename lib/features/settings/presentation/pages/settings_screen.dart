import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/theme/theme_controller.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/features/settings/presentation/widgets/settings_language_card.dart';
import 'package:lung_diagnosis_app/features/settings/presentation/widgets/settings_switch_tile_card.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/menu_item.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = AppStrings.english;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.settings,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSwitchTileCard(
            value: theme.isDark,
            onChanged: theme.setDark,
            title: 'Dark mode',
            subtitle: 'Use dark colors across the app',
            secondary: const Icon(Icons.dark_mode_rounded),
          ),
          SettingsLanguageCard(
            currentLanguage: _language,
            onChanged: (newValue) {
              if (newValue == null) return;
              setState(() => _language = newValue);
            },
          ),
          MenuItemWidget(
            imagePath: 'assets/icons/notification.svg',
            title: AppStrings.notificationSetting,
            onTap: () {},
          ),
          MenuItemWidget(
            imagePath: 'assets/icons/password.svg',
            title: AppStrings.changePass,
            onTap: () {},
          ),
          MenuItemWidget(
            imagePath: 'assets/icons/email.svg',
            title: AppStrings.changeMail,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
