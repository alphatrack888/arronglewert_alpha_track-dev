import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Canonical API leave type codes (matches time-tracker).
const kLeaveApiTypes = ['casual', 'sick', 'earn', 'wp'];

/// Default picker order when API balance list is empty.
const kDefaultLeaveApiTypes = kLeaveApiTypes;

/// Translation keys for apply-leave picker (one per API type).
String leaveUiKeyForApiType(String apiType) {
  switch (apiType.toLowerCase()) {
    case 'sick':
      return AppString.sickLeave;
    case 'earn':
      return AppString.earnLeave;
    case 'wp':
      return AppString.withoutPayleave;
    case 'casual':
    default:
      return AppString.casualLeave;
  }
}

/// Normalizes API `type` or legacy balance row strings to API code.
String normalizeLeaveApiType(String? raw) {
  if (raw == null || raw.isEmpty) return 'casual';
  final t = raw.trim().toLowerCase();
  if (kLeaveApiTypes.contains(t)) return t;
  if (t.contains('sick')) return 'sick';
  if (t.contains('earn')) return 'earn';
  if (t.contains('without') || t == 'wp') return 'wp';
  if (t.contains('casual')) return 'casual';
  return t;
}

String labelForApiType(String apiType) {
  return leaveUiKeyForApiType(normalizeLeaveApiType(apiType)).tr;
}

Color colorForApiType(String? apiType) {
  switch (normalizeLeaveApiType(apiType)) {
    case 'sick':
      return const Color(0xFFF5B6D0);
    case 'earn':
      return const Color(0xFF8FE0D0);
    case 'wp':
      return const Color(0xFFE9856B);
    case 'casual':
    default:
      return const Color(0xFFC7E89B);
  }
}

/// API code from a stored UI translation key (apply form).
String apiTypeFromUiKey(String uiKey) {
  if (uiKey == AppString.sickLeave) return 'sick';
  if (uiKey == AppString.casualLeave) return 'casual';
  if (uiKey == AppString.earnLeave) return 'earn';
  if (uiKey == AppString.withoutPayleave) return 'wp';
  return 'casual';
}
