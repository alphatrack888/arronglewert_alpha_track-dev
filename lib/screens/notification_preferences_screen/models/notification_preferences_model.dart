// Mirrors time-tracker's GET/PATCH /notification-preferences exactly (see
// notificationpreferences.interface.ts / .service.ts) — same shape the web
// dashboards' NotificationPreferencesModal already builds against
// (Phases 7/9).
class NotificationCategories {
  bool leave;
  bool project;
  bool payroll;
  bool overtime;
  bool attendance;
  bool subscription;

  NotificationCategories({
    this.leave = true,
    this.project = true,
    this.payroll = true,
    this.overtime = true,
    this.attendance = true,
    this.subscription = true,
  });

  factory NotificationCategories.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationCategories();
    return NotificationCategories(
      leave: json['leave'] ?? true,
      project: json['project'] ?? true,
      payroll: json['payroll'] ?? true,
      overtime: json['overtime'] ?? true,
      attendance: json['attendance'] ?? true,
      subscription: json['subscription'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'leave': leave,
        'project': project,
        'payroll': payroll,
        'overtime': overtime,
        'attendance': attendance,
        'subscription': subscription,
      };

  NotificationCategories copyWith({
    bool? leave,
    bool? project,
    bool? payroll,
    bool? overtime,
    bool? attendance,
    bool? subscription,
  }) {
    return NotificationCategories(
      leave: leave ?? this.leave,
      project: project ?? this.project,
      payroll: payroll ?? this.payroll,
      overtime: overtime ?? this.overtime,
      attendance: attendance ?? this.attendance,
      subscription: subscription ?? this.subscription,
    );
  }
}

class NotificationPreferences {
  bool pushEnabled;
  NotificationCategories categories;
  String digestMode; // 'realtime' | 'daily'
  String language; // 'en' | 'de'

  NotificationPreferences({
    this.pushEnabled = true,
    NotificationCategories? categories,
    this.digestMode = 'realtime',
    this.language = 'en',
  }) : categories = categories ?? NotificationCategories();

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushEnabled: json['pushEnabled'] ?? true,
      categories: NotificationCategories.fromJson(json['categories']),
      digestMode: json['digestMode'] ?? 'realtime',
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() => {
        'pushEnabled': pushEnabled,
        'categories': categories.toJson(),
        'digestMode': digestMode,
        'language': language,
      };
}
