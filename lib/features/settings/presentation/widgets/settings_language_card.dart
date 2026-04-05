import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

class SettingsLanguageCard extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String?> onChanged;

  const SettingsLanguageCard({
    super.key,
    required this.currentLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/language.svg',
              width: 24,
              height: 24,
              color: scheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppStrings.language,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DropdownButton<String>(
              value: currentLanguage,
              underline: const SizedBox(),
              dropdownColor: scheme.surface,
              iconEnabledColor: scheme.primary,
              onChanged: onChanged,
              items: [AppStrings.english, AppStrings.arabic].map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
