import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/storage/app_storage.dart';
import 'package:lung_diagnosis_app/core/storage/keys.dart';
import 'package:lung_diagnosis_app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blueAnimation;
  late Animation<double> _logoOpacity;

  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6));

    _blueAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.4, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addListener(() {
      if (!mounted) return;
      if (_controller.value >= 0.4) {
        setState(() {
          _progressValue = (_controller.value - 0.4) / 0.6;
        });
      }
    });

    _controller.addStatusListener((status) async {
      if (status != AnimationStatus.completed || !mounted) return;

      final hasSeen = await AppStorage.getBool(StorageKeys.hasSeenOnboarding);

      if (!mounted) return;

      final next = hasSeen ? AppRoutes.authGate : AppRoutes.onboarding;
      Navigator.pushNamedAndRemoveUntil(context, next, (_) => false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoSize = isDark ? 170.0 : 200.0;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height * _blueAnimation.value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        scheme.primary.withOpacity(0.92),
                        scheme.primary,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Center(
            child: AnimatedOpacity(
              opacity: _logoOpacity.value,
              duration: const Duration(milliseconds: 800),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/app_logo.png',
                    height: logoSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/lung_logo.png',
                        height: logoSize,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Pulmo Sense',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_controller.value >= 0.4)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 92),
                child: SizedBox(
                  width: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.white.withOpacity(0.16),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
