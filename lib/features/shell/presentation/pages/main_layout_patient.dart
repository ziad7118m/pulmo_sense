import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/home/presentation/pages/home_patient.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/pages/record_screen.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:lung_diagnosis_app/features/diagnosis/xray/presentation/pages/xray_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/pages/menu_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/navigation_bar.dart';

class MainLayoutPatient extends StatefulWidget {
  const MainLayoutPatient({super.key});

  @override
  State<MainLayoutPatient> createState() => _MainLayoutPatientState();
}

class _MainLayoutPatientState extends State<MainLayoutPatient> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePatient(
        onTabChange: (index) => setState(() => _currentIndex = index),
      ),
      const RecordScreen(isDoctor: false),
      const DashboardScreen(),
      const XRayScreen(isDoctor: false),
      const MenuScreen(isDoctor: false),
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
          role: 'patient',
          onTabChange: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}