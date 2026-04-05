import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/add_article_box.dart';

class DoctorHomePostBox extends StatelessWidget {
  final String profileImagePath;
  final VoidCallback onTap;

  const DoctorHomePostBox({
    super.key,
    required this.profileImagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StatusBox(
      profileImagePath: profileImagePath,
      uploadIconWidget: SvgPicture.asset(
        'assets/icons/image.svg',
        height: 19,
        width: 19,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
    );
  }
}
