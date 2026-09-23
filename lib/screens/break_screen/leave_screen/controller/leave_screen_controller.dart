import 'package:alpha_track/screens/break_screen/break_screen/controller/break_screen_controller.dart';
import 'package:alpha_track/services/repository/leave_management_repository/leave_management_repository.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
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

  //! Text controller for reason field
  final TextEditingController reasonController = TextEditingController();

  //! Dropdown options
  final List<String> leaveTypes = [
    AppString.annualLeave,
    AppString.sickLeave,
    AppString.casualLeave,
    AppString.earnLeave,
    AppString.withoutPayleave,
  ];

  //! Date picker controllers
  final DateRangePickerController fromDateController =
      DateRangePickerController();
  final DateRangePickerController toDateController =
      DateRangePickerController();

  //! Form validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  //! Convert UI leave type to API format
  String _getLeaveTypeForAPI(String leaveType) {
    if (leaveType == AppString.sickLeave) return 'sick';
    if (leaveType == AppString.annualLeave) return 'annual';
    if (leaveType == AppString.casualLeave) return 'casual';
    if (leaveType == AppString.earnLeave) return 'earn';
    if (leaveType == AppString.withoutPayleave) return 'wp';
    return 'casual'; // Default fallback
  }

  //! Format date for API (YYYY-MM-DD format)
  String _formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date).toString();
  }

  //! Validate form data before submission
  bool _validateLeaveApplication() {
    //! Form validation
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    //! Reason validation
    if (reason.value.trim().isEmpty) {
      AppSnackBar.error(AppString.pleaseEnterReasonForLeave.tr);
      return false;
    }

    //! Minimum leave duration validation
    if (leaveDuration < 1) {
      AppSnackBar.error(AppString.minOneDayLeave.tr);
      return false;
    }

    //! Date range validation
    if (toDate.value.isBefore(fromDate.value)) {
      AppSnackBar.error(AppString.invalidDateRange.tr);
      return false;
    }

    return true;
  }

  //! Submit leave application to API
  Future<void> submitLeaveApplication() async {
    //! Validate form data
    if (!_validateLeaveApplication()) {
      return;
    }

    try {
      isLoading(true);
      //! Get company ID from storage
      final companyId = _storageServices.getCompanyId();
      if (companyId.isEmpty) {
        AppSnackBar.error(AppString.companyIdNotFound.tr);
        return;
      }

      //! Prepare API parameters
      final String apiLeaveType = _getLeaveTypeForAPI(selectedLeaveType.value);
      final String fromDateFormatted = _formatDateForAPI(fromDate.value);
      final String toDateFormatted = _formatDateForAPI(toDate.value);
      final String leaveReason = reason.value.trim();

      //! Call API through repository
      final bool success = await _leaveRepository.applyforLeave(
        companyId: companyId,
        fromDate: fromDateFormatted,
        toDate: toDateFormatted,
        reason: leaveReason,
        type: apiLeaveType,
      );

      //! Handle API response
      if (success) {
        AppSnackBar.success(AppString.leaveApplicationSubmitted.tr);
        _resetFormAfterSuccess();
        //! Refresh break screen controller to update leave balance and UI
        final breakScreenController = Get.find<BreakScreenController>();
        await breakScreenController.updateLeaveData();
        //! Optional: Navigate back
        //! Get.back();
      } else {
        AppSnackBar.error(
          AppString.leaveApplicationFailed.tr,
        );
      }
    } catch (e) {
      AppSnackBar.error(
        AppString.leaveApplicationError.tr,
      );
    } finally {
      isLoading.value = false;
    }
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
