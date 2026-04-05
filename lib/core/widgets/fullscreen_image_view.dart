import 'package:flutter/material.dart';

/// Full-screen image viewer used across the app (profile, x-ray, articles).
///
/// - Supports pinch-to-zoom and pan.
/// - Uses an immersive dark background so medical images are easier to inspect.
class FullscreenImageView extends StatelessWidget {
  final ImageProvider image;
  final String? title;

  const FullscreenImageView({
    super.key,
    required this.image,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: title == null
            ? null
            : Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: double.infinity,
                      color: Colors.white.withOpacity(0.03),
                      child: InteractiveViewer(
                        minScale: 0.6,
                        maxScale: 5.0,
                        panEnabled: true,
                        child: Center(
                          child: Image(
                            image: image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Pinch to zoom and drag to inspect the image.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
