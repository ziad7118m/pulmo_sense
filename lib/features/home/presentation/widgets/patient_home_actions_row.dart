import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/home_action_card.dart';

class PatientHomeActionsRow extends StatelessWidget {
  final ValueChanged<int>? onTabChange;

  const PatientHomeActionsRow({
    super.key,
    this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: HomeActionCard(
            title: 'Cough',
            subtitle: 'Record audio',
            icon: SvgPicture.asset(
              'assets/icons/mic.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(scheme.primary, BlendMode.srcIn),
            ),
            onTap: () => onTabChange?.call(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HomeActionCard(
            title: AppStrings.xray,
            subtitle: 'Upload image',
            icon: SvgPicture.asset(
              'assets/icons/upload.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(scheme.primary, BlendMode.srcIn),
            ),
            onTap: () => onTabChange?.call(3),
          ),
        ),
      ],
    );
  }
}
