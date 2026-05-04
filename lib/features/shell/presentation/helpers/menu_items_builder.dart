import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/about/presentation/pages/about_screen.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/add_article_screen.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/articles_screen.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/favourite_articles_screen.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/my_articles_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/models/stethoscope_doctor_history_scope.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/presentation/pages/history_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/contact_doctor_screen.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/patient_access_screen.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/pages/add_medical_data_screen.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/pages/lung_risk_history_screen.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/pages/medical_data_screen.dart';
import 'package:lung_diagnosis_app/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/pages/my_qr_code_screen.dart';
import 'package:lung_diagnosis_app/features/settings/presentation/pages/settings_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/models/menu_action_item.dart';
import 'package:lung_diagnosis_app/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

List<MenuActionItem> buildMenuItems(BuildContext context, {required bool isDoctor}) {
  return isDoctor ? _doctorItems(context) : _patientItems(context);
}

List<MenuActionItem> _commonArticleItems(BuildContext context) {
  return [
    MenuActionItem(
      icon: Icons.article_rounded,
      title: AppStrings.medicalArticles,
      section: 'Content',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ArticlesScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.favorite_rounded,
      title: AppStrings.favouriteArticles,
      section: 'Content',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FavouriteArticlesScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.qr_code_rounded,
      title: 'My QR Code',
      section: 'Account',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyQrCodeScreen()),
      ),
    ),
  ];
}

List<MenuActionItem> _doctorItems(BuildContext context) {
  return [
    ..._commonArticleItems(context),
    MenuActionItem(
      icon: Icons.post_add_rounded,
      title: AppStrings.addArticle,
      section: 'Content',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddArticleScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.library_books_rounded,
      title: AppStrings.myArticles,
      section: 'Content',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyArticlesScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.dashboard_rounded,
      title: AppStrings.myDashboard,
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.people_alt_rounded,
      title: AppStrings.patientDashboard,
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PatientAccessScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.mic_rounded,
      title: AppStrings.lastRecord,
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DiagnosisHistoryScreen(kind: DiagnosisKind.record, isDoctor: true),
        ),
      ),
    ),
    MenuActionItem(
      icon: Icons.image_rounded,
      title: AppStrings.lastXray,
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DiagnosisHistoryScreen(kind: DiagnosisKind.xray, isDoctor: true),
        ),
      ),
    ),
    MenuActionItem(
      icon: Icons.analytics_rounded,
      title: 'Risk history',
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LungRiskHistoryScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.medical_services_rounded,
      title: 'Doctor account stethoscope exams',
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DiagnosisHistoryScreen(
            kind: DiagnosisKind.stethoscope,
            isDoctor: true,
            stethoscopeScope: StethoscopeDoctorHistoryScope.doctorPersonal,
          ),
        ),
      ),
    ),
    MenuActionItem(
      icon: Icons.groups_rounded,
      title: 'Patient stethoscope exams',
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DiagnosisHistoryScreen(
            kind: DiagnosisKind.stethoscope,
            isDoctor: true,
            stethoscopeScope: StethoscopeDoctorHistoryScope.doctorPatients,
          ),
        ),
      ),
    ),
    MenuActionItem(
      icon: Icons.playlist_add_check_circle_rounded,
      title: 'Update lung risk factors',
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddMedicalDataScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.medical_information_rounded,
      title: 'My medical data',
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedicalDataScreen()),
      ),
    ),
    ..._sharedUtilityItems(context),
  ];
}

List<MenuActionItem> _patientItems(BuildContext context) {
  return [
    ..._commonArticleItems(context),
    MenuActionItem(
      icon: Icons.dashboard_rounded,
      title: AppStrings.myDashboard,
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.mic_rounded,
      title: AppStrings.lastRecord,
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DiagnosisHistoryScreen(kind: DiagnosisKind.record, isDoctor: false),
        ),
      ),
    ),
    MenuActionItem(
      icon: Icons.image_rounded,
      title: AppStrings.lastXray,
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DiagnosisHistoryScreen(kind: DiagnosisKind.xray, isDoctor: false),
        ),
      ),
    ),
    MenuActionItem(
      icon: Icons.analytics_rounded,
      title: 'Risk history',
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LungRiskHistoryScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.medical_services_rounded,
      title: AppStrings.lastStethoscope,
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DiagnosisHistoryScreen(kind: DiagnosisKind.stethoscope, isDoctor: false),
        ),
      ),
    ),
    MenuActionItem(
      icon: Icons.medical_information_rounded,
      title: 'My medical data',
      section: 'Diagnosis & Dashboard',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedicalDataScreen()),
      ),
    ),
    ..._sharedUtilityItems(context),
  ];
}

List<MenuActionItem> _sharedUtilityItems(BuildContext context) {
  return [
    MenuActionItem(
      icon: Icons.settings_rounded,
      title: AppStrings.settings,
      section: 'Account',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.notifications_rounded,
      title: AppStrings.notifications,
      section: 'Account',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.contact_support_rounded,
      title: AppStrings.contactDoctor,
      section: 'Support',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ContactDoctorScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.info_rounded,
      title: AppStrings.aboutApp,
      section: 'Support',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AboutScreen()),
      ),
    ),
    MenuActionItem(
      icon: Icons.logout_rounded,
      title: AppStrings.logout,
      section: 'Support',
      isDestructive: true,
      onTap: () async {
        await context.read<AuthController>().logout();
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
    ),
  ];
}
