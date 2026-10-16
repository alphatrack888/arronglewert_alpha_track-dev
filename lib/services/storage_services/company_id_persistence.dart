import 'package:alpha_track/services/storage_services/storage_services.dart';

/// Sets company id only when [companyId] is non-empty and storage has none yet.
Future<void> persistCompanyIdIfMissing(String? companyId) async {
  if (companyId == null || companyId.isEmpty) return;

  final storage = StorageServices.instance;
  if (storage.getCompanyId().isNotEmpty) return;

  await storage.setCompanyId(companyId);
}

/// Avoids GET /leavebalance/company/ with an empty path segment.
bool shouldFetchLeaveBalance(String companyId) => companyId.isNotEmpty;
