class WaveformDownsampler {
  const WaveformDownsampler._();

  static List<double> downsampleMaxBuckets(List<double> input, int target) {
    if (input.isEmpty || target <= 0) return const [];

    final samples = input.map((e) => e.clamp(0.0, 1.0)).toList();
    if (samples.length <= target) return List<double>.from(samples);

    final out = <double>[];
    final bucketSize = samples.length / target;

    for (int i = 0; i < target; i++) {
      final start = (i * bucketSize).floor();
      final end = ((i + 1) * bucketSize).floor().clamp(0, samples.length);

      double maxValue = 0.0;
      for (int j = start; j < end; j++) {
        final sample = samples[j];
        if (sample > maxValue) maxValue = sample;
      }
      out.add(maxValue);
    }

    return out;
  }
}
