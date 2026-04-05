import 'package:flutter/material.dart';

class AboutDiseaseSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final List<String>? bullets;
  final bool emphasis;

  const AboutDiseaseSectionCard({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.bullets,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: (emphasis ? scheme.error : scheme.outlineVariant)
              .withOpacity(0.55),
          width: emphasis ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color:
                  (emphasis ? scheme.errorContainer : scheme.surfaceVariant)
                      .withOpacity(0.45),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: emphasis ? scheme.error : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    body!,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (bullets != null && bullets!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...bullets!.map(
                    (bullet) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              color: emphasis ? scheme.error : scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              bullet,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
