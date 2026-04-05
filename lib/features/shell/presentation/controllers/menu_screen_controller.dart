import 'package:lung_diagnosis_app/features/shell/presentation/models/menu_screen_view_data.dart';

class MenuScreenController {
  const MenuScreenController();

  MenuScreenViewData build({
    required String? currentUserName,
    required String? currentUserEmail,
    required String? avatarPath,
  }) {
    final normalizedName = (currentUserName ?? '').trim();
    return MenuScreenViewData(
      name: normalizedName.isEmpty ? 'User' : normalizedName,
      email: (currentUserEmail ?? '').trim(),
      avatarPath: (avatarPath ?? '').trim(),
    );
  }
}
