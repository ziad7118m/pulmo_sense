import 'dart:math';

class IdGenerator {
  IdGenerator._();

  static final Random _random = Random();

  static String next({String prefix = 'id'}) {
    final now = DateTime.now().toUtc().microsecondsSinceEpoch.toRadixString(36);
    final randomPart = List.generate(8, (_) => _alphabet[_random.nextInt(_alphabet.length)]).join();
    final cleanPrefix = prefix.trim().isEmpty ? 'id' : prefix.trim();
    return '${cleanPrefix}_$now$randomPart';
  }

  static const String _alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
}
