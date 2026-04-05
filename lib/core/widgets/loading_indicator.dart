import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: scheme.primary, strokeWidth: 4),
          const SizedBox(height: 16),
          Text(
            message ?? 'Loading...',
            style: TextStyle(fontSize: 18, color: scheme.primary),
          ),
        ],
      ),
    );
  }
}