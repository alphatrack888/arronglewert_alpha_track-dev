import 'package:alpha_track/screens/break_screen/break_screen/controller/break_screen_controller.dart';
import 'package:alpha_track/screens/break_screen/leave_screen/leave_type_display.dart';
import 'package:alpha_track/screens/break_screen/leave_screen/leave_type_mapping.dart';
import 'package:alpha_track/screens/break_screen/model/leave_balance_left.dart';
import 'package:alpha_track/services/repository/leave_management_repository/leave_apply_errors.dart';
import 'package:alpha_track/services/repository/leave_management_repository/leave_management_repository.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'dart:async';

import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class LeaveScreenController extends GetxController {
  //! Repository and storage services
  final LeaveManagementRepository _leaveRepository =
      LeaveManagementRepository();
  final StorageServices _storageServices = StorageServices.instance;

  //! Observable variables
  var selectedLeaveType = AppString.casualLeave.obs;
  var selectedLeaveConsumeType = 'Full Day'.obs;
  var fromDate = DateTime.now().obs;
  var toDate = DateTime.now().obs;
  var reason = ''.obs;
  var isLoading = false.obs;

  /// Inline feedback in the apply-leave sheet (top snackbars are hidden under
  /// the GetX bottom sheet overlay).
  final RxnString applyLeaveFeedbackMessage = RxnString();
  final RxBool applyLeaveFeedbackIsError = false.obs;

  //! Text controller for reason field
  final TextEditingController reasonController = TextEditingController();

  /// Fallback when [leaveTypesForPicker] has no API balance rows yet.
  static const List<String> defaultLeaveTypeUiKeys = [
    AppString.casualLeave,
    AppString.sickLeave,
    AppString.earnLeave,
    AppString.withoutPayleave,
  ];

  /// Picker options: API balance rows when loaded, else [defaultLeaveTypeUiKeys].
  List<String> leaveTypesForPicker() {
    final balances = Get.isRegistered<BreakScreenController>()
        ? Get.find<BreakScreenController>()
            .leaveBalanceHistoryData
            .value
            ?.data
            ?.companyLeaveBalance
        : null;
    if (balances == null || balances.isEmpty) {
      return List<String>.from(defaultLeaveTypeUiKeys);
    }
    final codes = balances
        .map((b) => normalizeLeaveApiType(b.type))
        .where((c) => kLeaveApiTypes.contains(c))
        .toSet();
    if (codes.isEmpty) return List<String>.from(defaultLeaveTypeUiKeys);
    return kDefaultLeaveApiTypes
        .where(codes.contains)
        .map(leaveUiKeyForApiType)
        .toList();
  }

  //! Date picker controllers
  final DateRangePickerController fromDateController =
      DateRangePickerController();
  final DateRangePickerController toDateController =
      DateRangePickerController();

  @override
  void onInit() {
    super.onInit();
    //! Initialize the reason controller
    reasonController.addListener(() {
      reason.value = reasonController.text;
    });

    //! Initialize dates to ensure minimum 1 day leave
    _initializeDates();
  }

  //! Initialize dates to current date (1 day leave by default)
  void _initializeDates() {
    final today = DateTime.now();
    fromDate.value = today;
    toDate.value = today;
  }

  //! Update leave type selection
  void updateLeaveType(String value) {
    selectedLeaveType.value = value;
  }

  //! Update leave consume type selection
  void updateLeaveConsumeType(String value) {
    selectedLeaveConsumeType.value = value;
  }

  //! Update from date and ensure valid date range
  void updateFromDate(DateTime date) {
    fromDate.value = date;

    //! If to date is before the new from date, set to date equal to from date
    //! This ensures minimum 1 day leave
    if (toDate.value.isBefore(date)) {
      toDate.value = date;
    }
  }

  //! Update to date with validation
  void updateToDate(DateTime date) {
    //! Validate that to date is not before from date
    if (date.isBefore(fromDate.value)) {
      AppSnackBar.error(
        AppString.toDateBeforeFromDate.tr,
      );
      return;
    }

    toDate.value = date;
  }

  //! Update reason text
  void updateReason(String value) {
    reason.value = value;
  }

  //! Calculate leave duration in days (minimum 1 day)
  int get leaveDuration {
    final duration = toDate.value.difference(fromDate.value).inDays + 1;
    return duration > 0 ? duration : 1;
  }

  //! Format date for API (YYYY-MM-DD format)
  String _formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date).toString();
  }

  void clearApplyLeaveFeedback() {
    applyLeaveFeedbackMessage.value = null;
  }

  void _showApplyLeaveFeedback(String message, {required bool isError}) {
    applyLeaveFeedbackMessage.value = message;
    applyLeaveFeedbackIsError.value = isError;
  }

  Future<void> _refreshLeaveDataAfterApply() async {
    if (!Get.isRegistered<BreakScreenController>()) return;
    try {
      await Get.find<BreakScreenController>().updateLeaveData();
    } catch (e, st) {
      appLog('Leave refresh after apply failed: $e\n$st');
    }
  }

  /// Apply leave from the Leave Schedule bottom sheet. Validates reason + dates,
  /// then in demo mode adds the
  /// leave locally so it shows up on the calendar / Upcoming section, or in real
  /// mode submits to the API. Returns true on success so the sheet can close.
  Future<bool> applyLeaveFromSheet() async {
    clearApplyLeaveFeedback();

    if (reason.value.trim().isEmpty) {
      _showApplyLeaveFeedback('vLeaveReason'.tr, isError: true);
      return false;
    }
    if (leaveDuration < 1 || toDate.value.isBefore(fromDate.value)) {
      _showApplyLeaveFeedback('vDateRange'.tr, isError: true);
      return false;
    }

    // Demo/review builds: no backend — add the leave to the local store so it
    // appears immediately (pending) on the calendar and Upcoming section.
    if (kDemoMode) {
      if (!_addDemoLeave()) {
        _showApplyLeaveFeedback(AppString.leaveApplicationFailed.tr, isError: true);
        return false;
      }
      _resetFormAfterSuccess();
      return true;
    }

    isLoading.value = true;
    try {
      final companyId = _storageServices.getCompanyId();
      if (companyId.isEmpty) {
        _showApplyLeaveFeedback(AppString.companyIdNotFound.tr, isError: true);
        return false;
      }
      final result = await _leaveRepository.applyforLeave(
        companyId: companyId,
        fromDate: _formatDateForAPI(fromDate.value),
        toDate: _formatDateForAPI(toDate.value),
        reason: reason.value.trim(),
        type: leaveTypeKeyToApi(selectedLeaveType.value),
      );
      if (result.success) {
        _resetFormAfterSuccess();
        // Refresh in background so the apply button does not stay loading.
        unawaited(_refreshLeaveDataAfterApply());
        return true;
      }
      _showApplyLeaveFeedback(
        leaveApplyFailureMessage(result),
        isError: true,
      );
      return false;
    } catch (e, st) {
      appLog('applyLeaveFromSheet unexpected: $e\n$st');
      _showApplyLeaveFeedback(AppString.leaveApplicationError.tr, isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Insert a pending leave into the in-memory leave data (demo mode only).
  /// Returns false if demo leave data is not loaded.
  bool _addDemoLeave() {
    final breakCtrl = Get.find<BreakScreenController>();
    final data = breakCtrl.leaveBalanceHistoryData.value?.data;
    if (data == null) return false;
    (data.leavemanagements ??= <Leavemanagement>[]).add(
      Leavemanagement(
        id: 'demo-${fromDate.value.microsecondsSinceEpoch}',
        type: leaveTypeKeyToApi(selectedLeaveType.value),
        status: 'pending',
        from: DateTime(
            fromDate.value.year, fromDate.value.month, fromDate.value.day),
        to: DateTime(toDate.value.year, toDate.value.month, toDate.value.day),
        totalDays: leaveDuration,
        reason: reason.value.trim(),
      ),
    );
    breakCtrl.leaveBalanceHistoryData.refresh();
    return true;
  }

  //! Reset form to initial state after successful submission
  void _resetFormAfterSuccess() {
    selectedLeaveType.value = AppString.casualLeave;
    selectedLeaveConsumeType.value = 'Full Day';
    reason.value = '';
    reasonController.clear();
    _initializeDates();
  }

  //! Public method to reset form manually
  void resetForm() {
    _resetFormAfterSuccess();
  }

  //! Get formatted date string for display
  String getFormattedDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  //! Check if leave application is currently being submitted
  bool get isSubmitting => isLoading.value;

  //! Get leave duration text for button
  String get leaveDurationText {
    final days = leaveDuration;
    return days == 1 ? '$days ${AppString.days.tr}' : '$days ${AppString.days.tr}';
  }

  //! Get button title based on loading state
  String get submitButtonTitle {
    if (isLoading.value) {
      return AppString.submitting.tr;
    }
    return '${AppString.applyFor.tr} $leaveDurationText ${AppString.leave.tr}';
  }

  //! Check if submit button should be enabled
  bool get isSubmitButtonEnabled => !isLoading.value;

  @override
  void onClose() {
    //! Dispose controllers to prevent memory leaks
    fromDateController.dispose();
    toDateController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
