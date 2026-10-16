import 'package:alpha_track/services/break_preference/break_preference_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manualBreak true maps to automatic off', () {
    expect(BreakPreferenceService.automaticFromManualBreak(true), false);
  });

  test('manualBreak false maps to automatic on', () {
    expect(BreakPreferenceService.automaticFromManualBreak(false), true);
  });

  test('manualBreak null uses default automatic on', () {
    expect(
      BreakPreferenceService.automaticFromManualBreak(null),
      BreakPreferenceService.defaultAutomaticBreakEnabled,
    );
  });

  test('manualBreak API field is inverse of automatic enabled', () {
    expect(BreakPreferenceService.manualBreakFromAutomatic(true), false);
    expect(BreakPreferenceService.manualBreakFromAutomatic(false), true);
  });

  test('profile manualBreak applies until user changes break settings', () {
    expect(BreakPreferenceService.shouldApplyProfileManualBreak(false), true);
    expect(BreakPreferenceService.shouldApplyProfileManualBreak(true), false);
  });
}
