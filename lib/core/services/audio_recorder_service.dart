import 'dart:async';
import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  final StreamController<double> _ampController =
  StreamController<double>.broadcast();

  Stream<double> get amplitudeStream => _ampController.stream;

  Timer? _ampTimer;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> start({required String path}) async {
    final ok = await hasPermission();
    if (!ok) {
      throw StateError('Microphone permission not granted');
    }

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    _ampTimer?.cancel();
    _ampTimer = Timer.periodic(const Duration(milliseconds: 80), (_) async {
      // record package provides amplitude
      final amp = await _recorder.getAmplitude();
      // amp.current is in dBFS (negative values); normalize
      final normalized = _dbToUnit(amp.current);
      _ampController.add(normalized);
    });
  }

  Future<String?> stop() async {
    _ampTimer?.cancel();
    _ampTimer = null;
    _ampController.add(0);

    return await _recorder.stop();
  }

  Future<void> cancel() async {
    _ampTimer?.cancel();
    _ampTimer = null;
    await _recorder.cancel();
    _ampController.add(0);
  }

  Future<void> dispose() async {
    _ampTimer?.cancel();
    await _ampController.close();
    await _recorder.dispose();
  }

  double _dbToUnit(double db) {
    // db عادة من -60 لحد 0
    // نحوله لـ 0..1
    final clamped = db.clamp(-60.0, 0.0);
    return (clamped + 60.0) / 60.0;
  }
}
