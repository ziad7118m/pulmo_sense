import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';

class ContactDoctorScreen extends StatelessWidget {
  const ContactDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.contactDoctor,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: scheme.primary.withOpacity(0.08)),
              boxShadow: [
                if (scheme.brightness == Brightness.light)
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ContactDoctorPlaceholder(scheme: scheme),
                const SizedBox(height: 24),
                Text(
                  AppStrings.comingSoon,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Direct doctor communication will be available in a future update. We’re preparing a clearer, safer, and more professional support flow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactDoctorPlaceholder extends StatelessWidget {
  final ColorScheme scheme;

  const _ContactDoctorPlaceholder({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withOpacity(0.12),
                  scheme.secondary.withOpacity(0.22),
                ],
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 32,
            child: _MiniBubble(icon: Icons.chat_bubble_outline_rounded, scheme: scheme),
          ),
          Positioned(
            bottom: 16,
            left: 28,
            child: _MiniBubble(icon: Icons.shield_outlined, scheme: scheme),
          ),
          Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.primary.withOpacity(0.12), width: 2),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: scheme.primary,
              size: 54,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBubble extends StatelessWidget {
  final IconData icon;
  final ColorScheme scheme;

  const _MiniBubble({required this.icon, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withOpacity(0.1)),
      ),
      child: Icon(icon, color: scheme.primary, size: 22),
    );
  }
}
