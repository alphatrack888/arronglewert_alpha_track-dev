import 'package:get/get.dart';

/// Server responses (notification titles/bodies) arrive in English. Map the
/// known phrases to translation keys so they render in the active locale;
/// anything unknown falls through untouched.
const Map<String, String> _serverTextKeys = {
  'You have received a new payrole': 'newPayrollTitle',
  'You have been assigned a new payrole, please see the document for more details':
      'newPayrollBody',
  'New Project Created': 'newProjectCreated',
  'A new project has been created': 'newProjectCreatedBody',
  'Project Updated': 'projectUpdated',
  'A project has been updated': 'projectUpdatedBody',
  'Project Deleted': 'projectDeleted',
  'A project has been deleted': 'projectDeletedBody',
  'Note Deleted': 'noteDeleted',
  'A note has been deleted': 'noteDeletedBody',
  'New Notification': 'newNotification',
  'You have a new notification': 'newNotificationBody',
};

String? localizeServerText(String? raw) {
  if (raw == null) return null;
  final key = _serverTextKeys[raw.trim()];
  return key == null ? raw : key.tr;
}
