import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/onboarding/presentation/models/onboarding_page_item.dart';

const List<OnboardingPageItem> onboardingItems = [
  OnboardingPageItem(
    overline: 'Pulmo Sense',
    title: 'Check respiratory signs with a calmer, smarter flow.',
    description:
        'Review cough recordings, stethoscope clips, and X-ray clues from one guided experience designed for clear follow-up.',
    supportingText:
        'Built to make first checks easier for both doctors and patients.',
    heroIcon: Icons.monitor_heart_outlined,
    badges: ['Audio screening', 'X-ray review', 'Clinical guidance'],
    accentColors: [
      Color(0xFF77B7FF),
      Color(0xFF1B5FBF),
      Color(0xFFBEE0FF),
    ],
  ),
  OnboardingPageItem(
    overline: 'Clean workflow',
    title: 'Record, upload, and review without losing context.',
    description:
        'Move through guided recording, quick previews, and diagnosis details with a polished workflow that stays simple under pressure.',
    supportingText:
        'Every step keeps the next action obvious and easy to reach.',
    heroIcon: Icons.graphic_eq_rounded,
    badges: ['Live record', 'Instant preview', 'Structured results'],
    accentColors: [
      Color(0xFF7FD8FF),
      Color(0xFF3478F6),
      Color(0xFFD9EEFF),
    ],
  ),
  OnboardingPageItem(
    overline: 'Stay organized',
    title: 'Keep dashboards, history, and medical data easy to follow.',
    description:
        'Track recent exams, supporting factors, articles, and patient views in one consistent interface that feels professional from day one.',
    supportingText:
        'Start with the experience that fits your role and continue from there.',
    heroIcon: Icons.dashboard_customize_outlined,
    badges: ['Patient follow-up', 'Article hub', 'Smart dashboard'],
    accentColors: [
      Color(0xFF95BFFF),
      Color(0xFF2452A5),
      Color(0xFFE5F1FF),
    ],
  ),
];
