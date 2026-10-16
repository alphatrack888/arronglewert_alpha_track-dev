class GalleryUploadResult {
  const GalleryUploadResult({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;
}
