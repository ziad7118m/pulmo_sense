import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_colors.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/bottom_arc_clipper.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/start_action_buttons.dart';
import 'package:lung_diagnosis_app/features/home/presentation/widgets/start_intro_section.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.45;
    const curveHeight = 80.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.onboarding1, AppColors.onboarding2],
            stops: [0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: ClipPath(
                  clipper: BottomArcClipper(curveHeight: curveHeight),
                  child: Image.asset(
                    'assets/images/start_image.jpg',
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              const StartIntroSection(),
              const SizedBox(height: 48),
              const StartActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
