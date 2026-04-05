import 'package:flutter/material.dart';
// NOTE: Requires adding `mobile_scanner` to pubspec.yaml.
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanCodeScreen extends StatefulWidget {
  const ScanCodeScreen({super.key});

  @override
  State<ScanCodeScreen> createState() => _ScanCodeScreenState();
}

class _ScanCodeScreenState extends State<ScanCodeScreen> {
  final MobileScannerController _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

  bool _handled = false;

  void _finish(String value) {
    if (_handled) return;
    _handled = true;
    Navigator.of(context).pop(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final raw = (barcodes.first.rawValue ?? '').trim();
              if (raw.isEmpty) return;
              _finish(raw);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface.withOpacity(0.92),
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: const Text(
                'Point the camera at a QR code or barcode containing the Patient Account ID or National ID.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
