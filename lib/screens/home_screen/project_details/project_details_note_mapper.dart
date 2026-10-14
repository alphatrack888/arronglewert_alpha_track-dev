import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/notes_screen/models/get_all_notes_models.dart';

/// Maps API note entities to the map shape used by project details note cards.
class ProjectDetailsNoteMapper {
  ProjectDetailsNoteMapper._();

  static String _formatNoteTime(DateTime? createdAt) {
    if (createdAt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12;
    final ap = createdAt.hour < 12 ? 'AM' : 'PM';
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year} • '
        '$h:${createdAt.minute.toString().padLeft(2, '0')} $ap';
  }

  static String _resolveMediaUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '${ApiUrls.liveDomain}$clean';
  }

  static Map<String, String> fromDatum(Datum note) {
    final raw = (note.content ?? '').trim();
    String title;
    String body;
    if (raw.isEmpty) {
      title = '';
      body = '';
    } else if (raw.contains('\n')) {
      final parts = raw.split('\n');
      title = parts.first.trim();
      body = parts.skip(1).join('\n').trim();
    } else {
      title = raw.length > 80 ? '${raw.substring(0, 80)}…' : raw;
      body = raw.length > 80 ? raw : '';
    }

    final images = (note.images ?? [])
        .where((e) => e.isNotEmpty)
        .map(_resolveMediaUrl)
        .join('|');

    final audio = (note.audio != null && note.audio!.isNotEmpty)
        ? _resolveMediaUrl(note.audio!.first)
        : '';

    return {
      'id': note.id ?? '',
      'title': title,
      'body': body,
      'author': note.createdBy?.name ?? 'Unknown',
      'time': _formatNoteTime(note.createdAt),
      'images': images,
      'audio': audio,
    };
  }

  static List<Map<String, String>> fromApiList(List<Datum> notes) {
    final sorted = List<Datum>.from(notes);
    sorted.sort((a, b) {
      final at = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at);
    });
    return sorted.map(fromDatum).toList();
  }
}
