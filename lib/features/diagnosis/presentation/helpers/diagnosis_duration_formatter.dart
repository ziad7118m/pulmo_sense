String formatDiagnosisDuration(Duration value) {
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String formatDiagnosisDurationSeconds(int seconds) {
  return formatDiagnosisDuration(Duration(seconds: seconds));
}
