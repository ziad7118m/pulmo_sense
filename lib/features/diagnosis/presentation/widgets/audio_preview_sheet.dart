import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/audio_preview_actions.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/audio_preview_progress_row.dart';

class AudioPreviewSheet extends StatefulWidget {
  final String audioPath;

  const AudioPreviewSheet({super.key, required this.audioPath});

  static void show(BuildContext context, String audioPath) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => AudioPreviewSheet(audioPath: audioPath),
    );
  }

  @override
  State<AudioPreviewSheet> createState() => _AudioPreviewSheetState();
}

class _AudioPreviewSheetState extends State<AudioPreviewSheet> {
  final AudioPlayer _player = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _player.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() => _duration = duration);
    });

    _player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final file = File(widget.audioPath);
    if (!file.existsSync()) return;

    if (_isPlaying) {
      await _player.pause();
      return;
    }

    await _player.play(DeviceFileSource(widget.audioPath));
  }

  Future<void> _seek(double value) async {
    if (_duration == Duration.zero) return;
    await _player.seek(Duration(milliseconds: value.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSeek = _duration != Duration.zero;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Audio preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          AudioPreviewProgressRow(
            position: _position,
            duration: _duration,
            onSeek: canSeek ? _seek : null,
          ),
          const SizedBox(height: 10),
          AudioPreviewActions(
            isPlaying: _isPlaying,
            onToggle: _toggle,
            onClose: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
