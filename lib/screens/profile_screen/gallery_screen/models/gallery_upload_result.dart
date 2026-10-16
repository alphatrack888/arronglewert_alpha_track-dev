import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_model.dart';

class GalleryUploadResult {
  const GalleryUploadResult({
    required this.success,
    this.message,
    this.createdItems = const [],
  });

  final bool success;
  final String? message;
  final List<Datum> createdItems;
}
