/// Picks one stored notification sentence for the app language.
///
/// The list request already does this on the server. Live socket payloads
/// still carry every language, so the phone applies the same rule.
class NotificationLocale {
  static const supported = ['english', 'german', 'arabic', 'romanian'];

  static String normalize(String? saved) {
    if (saved != null && supported.contains(saved)) return saved;
    return 'english';
  }

  static Map<String, dynamic> apply(
    Map<String, dynamic> data,
    String? savedLocale,
  ) {
    final copy = Map<String, dynamic>.from(data);
    final translations = copy['translations'];
    if (translations is! Map) return copy;

    final locale = normalize(savedLocale);
    final chosen = _pair(translations[locale]) ?? _pair(translations['english']);
    if (chosen == null) return copy;

    final title = chosen['title'];
    final body = chosen['body'];
    if (title is String && title.isNotEmpty) copy['title'] = title;
    if (body is String && body.isNotEmpty) copy['body'] = body;
    return copy;
  }

  static Map<dynamic, dynamic>? _pair(dynamic value) {
    if (value is! Map) return null;
    final title = value['title'];
    final body = value['body'];
    final hasTitle = title is String && title.isNotEmpty;
    final hasBody = body is String && body.isNotEmpty;
    if (!hasTitle && !hasBody) return null;
    return value;
  }
}
