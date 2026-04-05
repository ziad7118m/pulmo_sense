import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChange;
  final String role; // 'doctor' | 'patient'

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDoctor = role == 'doctor';
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final isLight = !isDark;

    // Patient Icons
    final patientLight = [
      'assets/icons/home.svg',
      'assets/icons/mic.svg',
      'assets/icons/dashboard.svg',
      'assets/icons/upload.svg',
      'assets/icons/menu.svg',
    ];

    final patientDark = [
      'assets/icons/home_s.svg',
      'assets/icons/mic_s.svg',
      'assets/icons/dashboard_s.svg',
      'assets/icons/upload_s.svg',
      'assets/icons/menu_s.svg',
    ];

    // Doctor Icons
    final doctorLight = [
      'assets/icons/home.svg',
      'assets/icons/mic.svg',
      'assets/icons/stethoscope.svg',
      'assets/icons/upload.svg',
      'assets/icons/menu.svg',
    ];

    final doctorDark = [
      'assets/icons/home_s.svg',
      'assets/icons/mic_s.svg',
      'assets/icons/stethoscope_s.svg',
      'assets/icons/upload_s.svg',
      'assets/icons/menu_s.svg',
    ];

    final lightIcons = isDoctor ? doctorLight : patientLight;
    final darkIcons = isDoctor ? doctorDark : patientDark;

    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: isLight ? scheme.primary : scheme.surface,
      height: 60,
      index: currentIndex,
      buttonBackgroundColor: Colors.transparent,
      items: List.generate(lightIcons.length, (index) {
        final bool isSelected = currentIndex == index;

        final BoxDecoration decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: (!isLight && isSelected) ? scheme.secondaryContainer : null,
          gradient: (isLight && isSelected)
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withOpacity(0.65),
              scheme.primary,
            ],
          )
              : null,
        );

        return Container(
          decoration: decoration,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: SvgPicture.asset(
              isSelected ? darkIcons[index] : lightIcons[index],
              width: 26,
              height: 26,
              fit: BoxFit.contain,
              colorFilter: isLight
                  ? ColorFilter.mode(
                isSelected
                    ? scheme.surface
                    : scheme.onPrimary.withOpacity(0.78),
                BlendMode.srcIn,
              )
                  : (isSelected
                  ? ColorFilter.mode(scheme.primary, BlendMode.srcIn)
                  : ColorFilter.mode(
                scheme.onSurfaceVariant,
                BlendMode.srcIn,
              )),
            ),
          ),
        );
      }),
      onTap: onTabChange,
    );
  }
}