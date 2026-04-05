import 'package:flutter/material.dart';

class RecordMicButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const RecordMicButton({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  State<RecordMicButton> createState() => _RecordMicButtonState();
}

class _RecordMicButtonState extends State<RecordMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant RecordMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRecording != widget.isRecording) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.isRecording) {
      _pulseController.repeat();
    } else {
      _pulseController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseColor = scheme.primary;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 132,
        height: 132,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isRecording) ...[
                  _PulseRing(
                    progress: _pulseController.value,
                    color: baseColor,
                    size: 108,
                  ),
                  _PulseRing(
                    progress: (_pulseController.value + 0.45) % 1,
                    color: baseColor,
                    size: 108,
                  ),
                ],
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isRecording
                          ? const [Color(0xFF5EA8FF), Color(0xFF2F7EF7)]
                          : [
                              scheme.primary.withOpacity(0.92),
                              scheme.primary,
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(widget.isRecording ? 0.28 : 0.20),
                        blurRadius: widget.isRecording ? 26 : 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: widget.isRecording
                          ? const Icon(
                              Icons.stop_rounded,
                              key: ValueKey('stop'),
                              color: Colors.white,
                              size: 34,
                            )
                          : const Icon(
                              Icons.mic_rounded,
                              key: ValueKey('mic'),
                              color: Colors.white,
                              size: 34,
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;

  const _PulseRing({
    required this.progress,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final scale = 1 + (progress * 0.56);
    final opacity = (1 - progress).clamp(0.0, 1.0) * 0.24;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(opacity),
            width: 7,
          ),
        ),
      ),
    );
  }
}
