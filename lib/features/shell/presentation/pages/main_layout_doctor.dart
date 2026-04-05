import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/home_doctor.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/pages/record_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/pages/stethoscope_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/pages/xray_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/pages/menu_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/navigation_bar.dart';

class MainLayoutDoctor extends StatefulWidget {
  const MainLayoutDoctor({super.key});

  @override
  State<MainLayoutDoctor> createState() => _MainLayoutDoctorState();
}

class _MainLayoutDoctorState extends State<MainLayoutDoctor> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeDoctor(
        onTabChange: (index) => setState(() => _currentIndex = index),
      ),
      const RecordScreen(isDoctor: true),
      const StethoscopeScreen(isDoctor: true), // ✅ FIX
      const XRayScreen(isDoctor: true),
      const MenuScreen(isDoctor: true),
    ];
  }

  void changeScreen(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // ✅ In bottom-nav flows, back should return to Home tab first.
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true; // exit app
      },
      child: Scaffold(
        body: SafeArea(child: _screens[_currentIndex]),
        bottomNavigationBar: CustomNavigationBar(
          currentIndex: _currentIndex,
          role: 'doctor',
          onTabChange: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
