import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_model.dart';

/// Result of parsing GET /gallery/.
class GalleryFetchOutcome {
  const GalleryFetchOutcome({
    required this.ok,
    this.items = const [],
    this.totalCount,
    this.serverMessage,
    this.errorKey = 'failedFetchGallery',
  });

  final bool ok;
  final List<Datum> items;
  /// From `meta.total` on GET /gallery/ (authoritative image count).
  final int? totalCount;
  final String? serverMessage;
  final String errorKey;
}

int? parseGalleryTotalFromMeta(dynamic meta) {
  if (meta is! Map) return null;
  final map = Map<String, dynamic>.from(meta);
  final total = map['total'];
  if (total is int) return total;
  if (total is num) return total.toInt();
  return null;
}

/// Result of parsing POST /gallery/ (after HTTP layer).
class GalleryUploadParseResult {
  const GalleryUploadParseResult({
    required this.success,
    this.message,
    this.createdItems = const [],
  });

  final bool success;
  final String? message;
  final List<Datum> createdItems;
}

String? mapUploadHttpStatusToMessageKey(int? statusCode) {
  if (statusCode == 401) return 'galleryUploadAuthRequired';
  if (statusCode == 403) return 'galleryUploadEmployeeOnly';
  return null;
}

List<Datum> parseGalleryDataList(dynamic data) {
  if (data is! List) return const [];
  return data
      .whereType<Map>()
      .map((e) => Datum.fromJson(Map<String, dynamic>.from(e)))
      .where((d) => d.image != null && d.image!.isNotEmpty)
      .toList();
}

GalleryFetchOutcome parseGalleryListResponse(dynamic body) {
  if (body is! Map) {
    return const GalleryFetchOutcome(ok: false);
  }
  final map = Map<String, dynamic>.from(body);
  if (map['success'] != true) {
    return GalleryFetchOutcome(
      ok: false,
      serverMessage: map['message']?.toString(),
    );
  }
  final items = parseGalleryDataList(map['data']);
  final totalCount = parseGalleryTotalFromMeta(map['meta']) ?? items.length;
  return GalleryFetchOutcome(
    ok: true,
    items: items,
    totalCount: totalCount,
    serverMessage: map['message']?.toString(),
  );
}

GalleryUploadParseResult parseGalleryUploadResponse(
  dynamic body,
  int? statusCode,
) {
  final statusKey = mapUploadHttpStatusToMessageKey(statusCode);
  if (statusKey != null) {
    return GalleryUploadParseResult(success: false, message: statusKey);
  }

  if (statusCode == null || statusCode < 200 || statusCode >= 300) {
    final serverMessage =
        body is Map ? body['message']?.toString() : null;
    return GalleryUploadParseResult(
      success: false,
      message: serverMessage,
    );
  }

  if (body is! Map || body['success'] != true) {
    final serverMessage =
        body is Map ? body['message']?.toString() : null;
    return GalleryUploadParseResult(
      success: false,
      message: serverMessage,
    );
  }

  final map = Map<String, dynamic>.from(body);
  return GalleryUploadParseResult(
    success: true,
    message: map['message']?.toString(),
    createdItems: parseGalleryDataList(map['data']),
  );
}

/// Merges lists for the grid: [created] first, then [existing], deduped by id.
/// If [fromServer] is non-empty it replaces the merged preview (authoritative GET).
List<Datum> mergeGalleryItems({
  required List<Datum> existing,
  List<Datum> created = const [],
  List<Datum> fromServer = const [],
}) {
  if (fromServer.isNotEmpty) {
    return List<Datum>.from(fromServer);
  }

  final seen = <String>{};
  final merged = <Datum>[];

  void addAll(List<Datum> source) {
    for (final item in source) {
      final id = item.id;
      if (id == null || id.isEmpty) continue;
      if (seen.add(id)) {
        merged.add(item);
      }
    }
  }

  addAll(created);
  addAll(existing);
  return merged;
}
