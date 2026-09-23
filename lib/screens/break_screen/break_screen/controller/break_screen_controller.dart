import 'package:alpha_track/screens/break_screen/model/leave_balance_left.dart';
import 'package:alpha_track/screens/break_screen/model/leave_balance_mdoel.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:get/get.dart';
import '../../../../services/repository/leave_management_repository/leave_management_repository.dart';

class BreakScreenController extends GetxController {
  final LeaveManagementRepository leaveManagementRepository =
      LeaveManagementRepository();
  
  // Removed break-related state variables
  RxBool isLoading = false.obs;
  RxBool isLeaveHistoryLoading = false.obs;

  Rxn<LeaveBalanceModel> leaveBalanceData = Rxn<LeaveBalanceModel>();
  Rxn<LeaveBalanceLeftModel> leaveBalanceHistoryData =
      Rxn<LeaveBalanceLeftModel>();

  // Removed break-related methods

  @override
  void onInit() {
    super.onInit();
    fetchLeaveBalance();
    fetchLeaveHistory(); // Fetch leave history on init since we only have leave section
  }

  void fetchLeaveBalance() async {
    try {
      isLoading(true);
      final response = await leaveManagementRepository
          .fetchAlltheLeaveBalance();
      leaveBalanceData.value = response;
      // Add this debug log
      appLog("Leave Balance Data: ${response.toRawJson()}");
      isLoading(false);
    } catch (e) {
      appLog("Error fetching leave balance: $e");
      isLoading(false);
    }
  }

  void fetchLeaveHistory() async {
    try {
      isLeaveHistoryLoading(true);
      final response = await leaveManagementRepository
          .fetchLeaveBalanceHistory();
      if(response.success == true){
        leaveBalanceHistoryData.value = response;
        appLog("Leave History Data: ${response.toRawJson()}");
      }
      isLeaveHistoryLoading(false);
    } catch (e) {
      appLog("Error fetching leave history: $e");
      isLeaveHistoryLoading(false);
    }
  }
  /// Refreshes both leave balance and leave history data.
  /// Sets the corresponding loading flags and updates the observable values.
  Future<void> updateLeaveData() async {
    await Future.wait([
      fetchLeaveBalance(),
      fetchLeaveHistory(),
    ] as Iterable<Future>);
  }

  // /// Refreshes only the leave balance.
  // /// Keeps leave history untouched.
  // Future<void> updateLeaveBalanceOnly() async {
  //   await fetchLeaveBalance();
  // }

  // /// Refreshes only the leave history.
  // /// Keeps leave balance untouched.
  // Future<void> updateLeaveHistoryOnly() async {
  //   await fetchLeaveHistory();
  // }
}
