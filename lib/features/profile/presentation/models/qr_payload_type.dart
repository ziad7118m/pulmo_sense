enum QrPayloadType {
  accountId,
  nationalId;

  String get label {
    switch (this) {
      case QrPayloadType.accountId:
        return 'Account ID';
      case QrPayloadType.nationalId:
        return 'National ID';
    }
  }

  String get title {
    switch (this) {
      case QrPayloadType.accountId:
        return 'Account ID';
      case QrPayloadType.nationalId:
        return 'National ID';
    }
  }
}
