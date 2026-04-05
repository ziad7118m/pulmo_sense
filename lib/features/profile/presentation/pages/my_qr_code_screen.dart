import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/controllers/my_qr_code_controller.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/qr_code_preview_card.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/qr_code_value_card.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/qr_payload_selector_card.dart';
import 'package:provider/provider.dart';

class MyQrCodeScreen extends StatefulWidget {
  const MyQrCodeScreen({super.key});

  @override
  State<MyQrCodeScreen> createState() => _MyQrCodeScreenState();
}

class _MyQrCodeScreenState extends State<MyQrCodeScreen> {
  late final MyQrCodeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MyQrCodeController(
      authController: context.read<AuthController>(),
      profileController: context.read<ProfileController>(),
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final viewData = _controller.viewData;
        final payload = viewData.payload;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My QR Code'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                QrPayloadSelectorCard(
                  selectedType: viewData.selectedType,
                  hasNationalId: viewData.hasNationalId,
                  onChanged: _controller.selectPayloadType,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: QrCodePreviewCard(payload: payload)),
                      if (viewData.isLoading)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Color(0x66FFFFFF),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
                ),
                if (payload != null)
                  QrCodeValueCard(
                    payloadType: viewData.selectedType,
                    payload: payload,
                    onCopy: () => _copy(payload),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
