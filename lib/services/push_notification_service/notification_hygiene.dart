/// What the preferences screen shows for the phone's own notification permission.
/// The server switch is a separate value and is not derived from this.
enum OsNotificationAction { allow, openSettings }

class OsNotificationPrompt {
  final bool showStatus;
  final OsNotificationAction action;

  const OsNotificationPrompt({
    required this.showStatus,
    required this.action,
  });
}

/// [allowed] is Firebase authorized or provisional. A permanent denial cannot
/// show the system dialog again, so the button opens the app's system page.
OsNotificationPrompt osNotificationPrompt({
  required bool allowed,
  required bool permanentlyDenied,
}) {
  if (allowed) {
    return const OsNotificationPrompt(
      showStatus: false,
      action: OsNotificationAction.allow,
    );
  }
  if (permanentlyDenied) {
    return const OsNotificationPrompt(
      showStatus: true,
      action: OsNotificationAction.openSettings,
    );
  }
  return const OsNotificationPrompt(
    showStatus: true,
    action: OsNotificationAction.allow,
  );
}

/// How a quiet device-delete result treats the saved logout token.
/// Both 404 outcomes drop the local pair. They stay distinct because a 404
/// for another user does not mean that user's row was removed.
enum PendingDeleteDecision {
  deleted,
  alreadyGone,
  notAllowed,
  keep,
}

bool pendingDeleteClears(PendingDeleteDecision decision) {
  return decision != PendingDeleteDecision.keep;
}

PendingDeleteDecision pendingDeleteDecision({
  required int? statusCode,
  required String savedUserId,
  required String currentUserId,
}) {
  if (statusCode == 200) return PendingDeleteDecision.deleted;
  if (statusCode == 404) {
    if (savedUserId.isNotEmpty && savedUserId == currentUserId) {
      return PendingDeleteDecision.alreadyGone;
    }
    return PendingDeleteDecision.notAllowed;
  }
  return PendingDeleteDecision.keep;
}
