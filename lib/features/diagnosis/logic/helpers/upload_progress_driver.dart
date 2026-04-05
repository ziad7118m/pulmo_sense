import 'dart:async';

class UploadProgressDriver {
  final Duration interval;
  final double step;
  final void Function(double value) onProgress;

  Timer? _timer;

  UploadProgressDriver({
    required this.onProgress,
    this.interval = const Duration(milliseconds: 120),
    this.step = 0.08,
  });

  void start({double from = 0.0}) {
    stop();

    var current = from;
    onProgress(current);

    _timer = Timer.periodic(interval, (_) {
      current += step;
      if (current >= 1.0) {
        current = 1.0;
        onProgress(current);
        stop();
        return;
      }
      onProgress(current);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
  }
}
