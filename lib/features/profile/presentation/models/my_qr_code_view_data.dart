import 'package:lung_diagnosis_app/features/profile/presentation/models/qr_payload_type.dart';

class MyQrCodeViewData {
  final QrPayloadType selectedType;
  final String? userId;
  final String? nationalId;
  final bool isLoading;

  const MyQrCodeViewData({
    required this.selectedType,
    required this.userId,
    required this.nationalId,
    required this.isLoading,
  });

  bool get hasNationalId => nationalId != null;

  String? get payload {
    switch (selectedType) {
      case QrPayloadType.accountId:
        return userId;
      case QrPayloadType.nationalId:
        return nationalId;
    }
  }
}
