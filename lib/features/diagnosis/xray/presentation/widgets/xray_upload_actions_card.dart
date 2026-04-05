import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

class XrayUploadActionsCard extends StatelessWidget {
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;

  const XrayUploadActionsCard({
    super.key,
    required this.onPickGallery,
    required this.onPickCamera,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withOpacity(0.08),
            scheme.surface,
          ],
        ),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose upload method',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload from your gallery or capture a fresh image directly from the camera. You can preview and zoom before sending.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _XrayUploadActionTile(
                  icon: Icons.photo_library_outlined,
                  title: AppStrings.gallery,
                  subtitle: 'Choose an existing X-ray image from your device.',
                  onTap: onPickGallery,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _XrayUploadActionTile(
                  icon: Icons.add_a_photo_outlined,
                  title: AppStrings.camera_xray,
                  subtitle: 'Open camera and capture the scan instantly.',
                  onTap: onPickCamera,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _XrayUploadActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _XrayUploadActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outlineVariant),
            color: scheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: scheme.primary.withOpacity(0.10),
                ),
                child: Icon(icon, color: scheme.primary, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
