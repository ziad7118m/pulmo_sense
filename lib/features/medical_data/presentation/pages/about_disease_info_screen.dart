import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/helpers/about_disease_content.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/about_disease_hero_card.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/about_disease_section_card.dart';

class AboutDiseaseInfoScreen extends StatelessWidget {
  final String title;
  final String description;

  const AboutDiseaseInfoScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = AboutDiseaseContent.from(
      title: title,
      description: description,
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        showBack: true,
        elevation: 0,
        backgroundColor: scheme.surface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            AboutDiseaseHeroCard(
              title: title,
              subtitle: content.heroDescription,
            ),
            const SizedBox(height: 14),
            AboutDiseaseSectionCard(
              icon: Icons.info_outline_rounded,
              title: 'Overview',
              body: content.overview,
            ),
            const SizedBox(height: 12),
            AboutDiseaseSectionCard(
              icon: Icons.search_rounded,
              title: 'What to watch for',
              bullets: content.watchFor,
            ),
            const SizedBox(height: 12),
            AboutDiseaseSectionCard(
              icon: Icons.health_and_safety_rounded,
              title: 'Ways to reduce risk',
              bullets: content.reduceRisk,
            ),
            const SizedBox(height: 12),
            AboutDiseaseSectionCard(
              icon: Icons.emergency_rounded,
              title: 'When to seek urgent help',
              bullets: content.urgentHelp,
              emphasis: true,
            ),
            const SizedBox(height: 14),
            AboutDiseaseSectionCard(
              icon: Icons.verified_rounded,
              title: 'Sources',
              body: content.sources,
            ),
          ],
        ),
      ),
    );
  }
}
