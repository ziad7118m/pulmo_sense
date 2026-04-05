enum MediaSourceType { recorded, uploaded, imageCapture, imageUpload }

extension MediaSourceTypeX on MediaSourceType {
  String get apiValue => name;
}
