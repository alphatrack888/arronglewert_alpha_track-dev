import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/break_screen/break_screen/controller/break_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// Data source class for leave balance table
class LeaveBalanceDataSource extends DataGridSource {
  final BreakScreenController controller;

  LeaveBalanceDataSource(this.controller) {
    _buildDataRows();
  }

  List<DataGridRow> _dataRows = [];

  void _buildDataRows() {
    final companyLeaveBalance =
        controller.leaveBalanceHistoryData.value?.data?.companyLeaveBalance;

    if (companyLeaveBalance != null) {
      _dataRows = List.generate(
        companyLeaveBalance.length,
        (index) => DataGridRow(
          cells: [
            DataGridCell<String>(
              columnName: 'type',
              value: companyLeaveBalance[index].type ?? 'N/A',
            ),
            DataGridCell<String>(
              columnName: 'taken',
              value: companyLeaveBalance[index].taken?.toString() ?? '0',
            ),
            DataGridCell<String>(
              columnName: 'balance',
              value: companyLeaveBalance[index].balance?.toString() ?? '0',
            ),
          ],
        ),
      );
    } else {
      _dataRows = [];
    }
  }

  @override
  List<DataGridRow> get rows => _dataRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Container(
          alignment: cell.columnName == 'type'
              ? Alignment.centerLeft
              : Alignment.center,
          padding: EdgeInsets.all(4.0),
          child: AppText(
            text: cell.value.toString(),
            fontSize: AppSize.width(value: 13),
            fontWeight: FontWeight.w700,
            color: AppColors.black500,
            maxLines: cell.columnName == 'type' ? 2 : 1,
            textAlign: cell.columnName == 'type'
                ? TextAlign.start
                : TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  void updateDataSource() {
    _buildDataRows();
    notifyListeners();
  }
}

// Data source class for break history table (static data)
class BreakHistoryDataSource extends DataGridSource {
  final BreakScreenController controller;

  BreakHistoryDataSource(this.controller) {
    _buildDataRows();
  }

  List<DataGridRow> _dataRows = [];

  void _buildDataRows() {
    final leavemanagements =
        controller.leaveBalanceHistoryData.value?.data?.leavemanagements;
    if (leavemanagements != null) {
      _dataRows = List.generate(
        leavemanagements.length,
        (index) => DataGridRow(
          cells: [
            DataGridCell<String>(
              columnName: 'type',
              value: leavemanagements[index].type ?? 'N/A',
            ),
            DataGridCell<String>(
              columnName: 'taken',
              value: leavemanagements[index].totalDays?.toString() ?? '0',
            ),
            DataGridCell<String>(
              columnName: 'balance',
              value: _formatDate(leavemanagements[index].createdAt),
            ),
            DataGridCell<String>(
              columnName: 'status',
              value: leavemanagements[index].status ?? 'N/A',
            ),
          ],
        ),
      );
    } else {
      _dataRows = [];
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  List<DataGridRow> get rows => _dataRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Container(
          alignment: cell.columnName == 'type'
              ? Alignment.centerLeft
              : Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: AppText(
            text: cell.value.toString(),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black500,
            maxLines: cell.columnName == 'type' ? 2 : 1,
            textAlign: cell.columnName == 'type'
                ? TextAlign.start
                : TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  void updateDataSource() {
    _buildDataRows();
    notifyListeners();
  }
}

class BreakScreen extends StatefulWidget {
  const BreakScreen({super.key});

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  final BreakScreenController controller = Get.find<BreakScreenController>();
  late LeaveBalanceDataSource leaveBalanceDataSource;
  late BreakHistoryDataSource breakHistoryDataSource;

  @override
  void initState() {
    super.initState();
    leaveBalanceDataSource = LeaveBalanceDataSource(controller);
    breakHistoryDataSource = BreakHistoryDataSource(controller);
  }

  Widget _buildDataGrid(
    DataGridSource dataSource, {
    bool isLeaveBalance = false,
  }) {
    return Container(
      height: AppSize.height(value: 322),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black200.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SfDataGrid(
        source: dataSource,
        columnWidthMode: ColumnWidthMode.fill,
        headerGridLinesVisibility: GridLinesVisibility.both,
        gridLinesVisibility: GridLinesVisibility.both,
        headerRowHeight: 45,
        rowHeight: 58,
        columns: <GridColumn>[
          GridColumn(
            columnName: 'type',
            label: Container(
              padding: EdgeInsets.all(4.0),
              alignment: Alignment.centerLeft,
              child: AppText(
                text: AppString.type.tr,
                fontSize: AppSize.width(value: 14),
                fontWeight: FontWeight.w400,
                color: AppColors.black200,
              ),
            ),
          ),
          GridColumn(
            columnName: 'taken',
            label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: AppText(
                text: AppString.taken.tr,
                fontSize: AppSize.width(value: 14),
                fontWeight: FontWeight.w400,
                color: AppColors.black200,
              ),
            ),
          ),
          GridColumn(
            columnName: 'balance',
            label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: AppText(
                text: isLeaveBalance
                    ? AppString.balance.tr
                    : AppString.appliedDate.tr,
                fontSize: AppSize.width(value: 14),
                fontWeight: FontWeight.w400,
                color: AppColors.black200,
              ),
            ),
          ),
          if (!isLeaveBalance)
            GridColumn(
              columnName: 'status',
              label: Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: AppText(
                  text: AppString.status.tr,
                  fontSize: AppSize.width(value: 14),
                  fontWeight: FontWeight.w400,
                  color: AppColors.black200,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.leaveManagement.tr,
        showAction: false,
        showLeading: false,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(height: AppSize.height(value: 15)),
                AppText(
                  text: AppString.leaveBalance.tr,
                  fontSize: AppSize.width(value: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black500,
                ),
                Gap(height: AppSize.height(value: 10)),
                // First DataGrid for Leave Balance
                Obx(() {
                  // Update data source when controller data changes
                  leaveBalanceDataSource.updateDataSource();
                  return _buildDataGrid(
                    leaveBalanceDataSource,
                    isLeaveBalance: true,
                  );
                }),
                Gap(height: AppSize.height(value: 10)),
                // Apply Leave Button
                AppButton(
                  title: AppString.applyLeave.tr,
                  onTap: () {
                    Get.toNamed(AppRoute.leaveScreen);
                  },
                  titleColor: AppColors.white200,
                  backgroundColor: AppColors.blue500,
                ),
                Gap(height: AppSize.height(value: 20)),
                AppText(
                  text: AppString.leaveHistory.tr,
                  fontSize: AppSize.width(value: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black500,
                ),
                Gap(height: AppSize.height(value: 10)),
                // Second DataGrid for Leave History
                Obx(() {
                  // Update data source when controller data changes
                  breakHistoryDataSource.updateDataSource();
                  return controller.isLeaveHistoryLoading.value
                      ? Container(
                          height: AppSize.height(value: 260),
                          child: Center(
                            child: LoadingAnimationWidget.beat(
                              size: 50,
                              color: AppColors.blue500,
                            ),
                          ),
                        )
                      : _buildDataGrid(
                          breakHistoryDataSource,
                          isLeaveBalance: false,
                        );
                }),
                Gap(height: AppSize.height(value: 50)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
