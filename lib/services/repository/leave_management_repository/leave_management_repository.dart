import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/break_screen/model/leave_balance_left.dart';
import 'package:alpha_track/screens/break_screen/model/leave_balance_mdoel.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';

class LeaveManagementRepository {
  ApiServices apiServices = ApiServices.instance;
  StorageServices storageServices = StorageServices.instance;

  Future<LeaveBalanceModel> fetchAlltheLeaveBalance() async {
    try {
      final companyId = storageServices.getCompanyId();
      final response = await apiServices.apiGetServices(
        ApiUrls.leaveBalance + companyId,
      );
      if (response["success"] == true) {
        return LeaveBalanceModel.fromJson(response);
      }
      return LeaveBalanceModel();
    } catch (e) {
      appLog(e.toString());
      return LeaveBalanceModel();
    }
  }

  //! Apply for leave
  Future<bool> applyforLeave({
    required String companyId,
    required String fromDate,
    required String toDate,
    required String reason,
    required String type,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "company": companyId,
        "from": fromDate,
        "to": toDate,
        "reason": reason,
        "type": type,
      };
      final response = await apiServices.apiPostServices(
        url: ApiUrls.leaveManagement,
        body: body,
      );
      if (response["success"] == true) {
        return true;
      }
      return false;
    } catch (e) {
      appLog(e.toString());
      return false;
    }
  }

  //! Get leave balance history
  Future<LeaveBalanceLeftModel> fetchLeaveBalanceHistory() async {
    try {
      final response = await apiServices.apiGetServices(
        ApiUrls.leaveManagement,
      );
      if (response["success"] == true) {
        return LeaveBalanceLeftModel.fromJson(response);
      }
      return LeaveBalanceLeftModel();
    } catch (e) {
      appLog(e.toString());
      return LeaveBalanceLeftModel();
    }
  }
}
