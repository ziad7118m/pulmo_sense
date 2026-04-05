import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/recording_wave_painters.dart';

class RecordingWave extends StatefulWidget {
  final bool isRecording;
  final double level;
  final List<double>? samples;
  final int intervalMs;
  final double smoothing;
  final double gain;
  final int endHoldMs;

  const RecordingWave({
    super.key,
    required this.isRecording,
    required this.level,
    this.samples,
    this.intervalMs = 82,
    this.smoothing = 0.86,
    this.gain = 0.90,
    this.endHoldMs = 420,
  });

  @override
  State<RecordingWave> createState() => _RecordingWaveState();
}

class _RecordingWaveState extends State<RecordingWave>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  static const double _barWidth = 4.0;
  static const double _spacing = 3.2;
  static const double _floor = 0.045;

  double get _step => _barWidth + _spacing;
  bool get _useStatic => widget.samples != null;

  double _filtered = 0.0;
  double _barProgress = 0.0;
  int _maxBars = 0;
  double _phase = 0.0;
  bool _scrolling = false;
  double _holdTimer = 0.0;
  Duration _last = Duration.zero;
  int _sampleIndex = 0;

  final List<double> _fillBars = [];
  final List<double> _scrollBars = [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant RecordingWave oldWidget) {
    super.didUpdateWidget(oldWidget);

    final settingsChanged =
        (oldWidget.samples != null) != (widget.samples != null) ||
            oldWidget.isRecording != widget.isRecording ||
            oldWidget.intervalMs != widget.intervalMs ||
            oldWidget.smoothing != widget.smoothing ||
            oldWidget.gain != widget.gain ||
            oldWidget.endHoldMs != widget.endHoldMs;

    if (!settingsChanged) return;

    if (!_useStatic && !oldWidget.isRecording && widget.isRecording) {
      _resetLive();
    }

    _syncTicker();
  }

  void _resetLive() {
    _filtered = 0.0;
    _barProgress = 0.0;
    _phase = 0.0;
    _scrolling = false;
    _holdTimer = 0.0;
    _sampleIndex = 0;
    _fillBars.clear();
    _scrollBars.clear();
    _last = Duration.zero;
  }

  void _syncTicker() {
    if (_useStatic) {
      _ticker.stop();
      return;
    }

    if (widget.isRecording) {
      if (!_ticker.isActive) {
        _ticker.start();
      }
      return;
    }

    _ticker.stop();
    _phase = 0.0;
    _holdTimer = 0.0;
  }

  double _shapeInput(double raw) {
    final alpha = widget.smoothing.clamp(0.0, 0.97);
    _filtered = (_filtered * alpha) + (raw * (1 - alpha));

    final gained = (_filtered * widget.gain).clamp(0.0, 1.0);
    final contour = pow(gained, 0.72).toDouble();
    final pulse = 0.06 * sin((_sampleIndex * 0.82) + 0.45);
    final flutter = 0.03 * cos((_sampleIndex * 0.33) + 1.2);
    final shaped = (contour + pulse + flutter).clamp(_floor, 1.0);

    return shaped;
  }

  void _onTick(Duration elapsed) {
    if (!mounted || _useStatic || !widget.isRecording) return;

    final dt = _last == Duration.zero
        ? 0.016
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;

    if (_holdTimer > 0) {
      _holdTimer = max(0.0, _holdTimer - dt);
      setState(() {});
      return;
    }

    final intervalSec = max(0.045, widget.intervalMs / 1000.0);
    final barsPerSec = 1.0 / intervalSec;

    _barProgress += dt * barsPerSec;
    final value = _shapeInput(widget.level.clamp(0.0, 1.0));

    while (_barProgress >= 1.0) {
      _barProgress -= 1.0;
      _sampleIndex += 1;

      if (!_scrolling) {
        if (_maxBars > 0 && _fillBars.length < _maxBars) {
          _fillBars.add(value);
        }

        if (_maxBars > 0 && _fillBars.length >= _maxBars) {
          _holdTimer = widget.endHoldMs / 1000.0;
          _scrolling = true;
          _phase = 0.0;
          _scrollBars
            ..clear()
            ..addAll(_fillBars);
        }
      } else {
        _scrollBars.add(value);

        final keep = _maxBars + 8;
        if (_scrollBars.length > keep) {
          _scrollBars.removeRange(0, _scrollBars.length - keep);
        }
      }
    }

    if (_scrolling) {
      const scrollSpeed = 0.68;
      _phase += dt * barsPerSec * scrollSpeed;
      if (_phase >= 1.0) {
        _phase -= 1.0;
      }
    }

    setState(() {});
  }

  double _totalHeightFor(double level) {
    final shaped = pow(level.clamp(0.0, 1.0), 0.82).toDouble();
    const minTotal = 8.0;
    const maxTotal = 68.0;
    return minTotal + (shaped * (maxTotal - minTotal));
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveColor = Theme.of(context).colorScheme.secondary;

    if (_useStatic) {
      return CustomPaint(
        painter: StaticWavePainter(
          color: waveColor,
          samples: widget.samples ?? const [],
          barWidth: _barWidth,
          spacing: _spacing,
          totalHeightFor: _totalHeightFor,
        ),
        size: Size.infinite,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBars = (constraints.maxWidth / _step).floor().clamp(1, 9999);

        if (maxBars != _maxBars) {
          _maxBars = maxBars;

          if (_fillBars.length > _maxBars) {
            _fillBars.removeRange(_maxBars, _fillBars.length);
          }

          final keep = _maxBars + 8;
          if (_scrollBars.length > keep) {
            _scrollBars.removeRange(0, _scrollBars.length - keep);
          }
        }

        final barsToDraw = _scrolling ? _scrollBars : _fillBars;

        return CustomPaint(
          painter: LiveWavePainter(
            bars: barsToDraw,
            barWidth: _barWidth,
            spacing: _spacing,
            phase: _scrolling ? _phase : 0.0,
            totalHeightFor: _totalHeightFor,
            color: waveColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
