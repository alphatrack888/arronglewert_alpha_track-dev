import 'dart:ui';

import 'package:alpha_track/screens/reports_screen/controller/reports_screen_controller.dart';
import 'package:alpha_track/screens/reports_screen/report_pdf_viewer_screen.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsScreenController());

    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.report.tr,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSize.width(value: 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _typeToggle(controller),
            Gap(height: AppSize.height(value: 16)),
            Obx(
              () => controller.reportType.value == 'monthly'
                  ? _monthlyForm(controller)
                  : _attendanceForm(controller),
            ),
            Gap(height: AppSize.height(value: 16)),
            _formatAndLanguageRow(controller),
            Gap(height: AppSize.height(value: 20)),
            Obx(
              () => AppButton(
                height: AppSize.height(value: 48),
                title: controller.state.value == ReportGenerationState.generating
                    ? '...'
                    : AppString.downloadReport.tr,
                titleColor: AppColors.white100,
                backgroundColor: AppColors.blue500,
                onTap: controller.state.value == ReportGenerationState.generating
                    ? () {}
                    : controller.generateReport,
              ),
            ),
            Gap(height: AppSize.height(value: 20)),
            Obx(() => _resultSection(controller)),
          ],
        ),
      ),
    );
  }

  Widget _typeToggle(ReportsScreenController controller) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: AppButton(
              height: AppSize.height(value: 40),
              title: AppString.timesheetReport.tr,
              titleColor: controller.reportType.value == 'monthly'
                  ? AppColors.white100
                  : AppColors.blue500,
              backgroundColor: controller.reportType.value == 'monthly'
                  ? AppColors.blue500
                  : AppColors.white200,
              borderColor: AppColors.blue500,
              onTap: () {
                controller.reportType.value = 'monthly';
                controller.reset();
              },
            ),
          ),
          Gap(width: AppSize.width(value: 10)),
          Expanded(
            child: AppButton(
              height: AppSize.height(value: 40),
              title: AppString.attendanceReport.tr,
              titleColor: controller.reportType.value == 'attendance'
                  ? AppColors.white100
                  : AppColors.blue500,
              backgroundColor: controller.reportType.value == 'attendance'
                  ? AppColors.blue500
                  : AppColors.white200,
              borderColor: AppColors.blue500,
              onTap: () {
                controller.reportType.value = 'attendance';
                controller.reset();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthlyForm(ReportsScreenController controller) {
    // Last 12 months, matching the equivalent web pattern (EmployeeReportModal).
    final now = DateTime.now();
    final months = List.generate(12, (i) {
      final d = DateTime(now.year, now.month - i, 1);
      return d;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: AppString.month.tr, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black500),
        Gap(height: AppSize.height(value: 8)),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black100),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: controller.month.value,
                items: months.map((d) {
                  final value = '${d.year}-${d.month.toString().padLeft(2, '0')}';
                  return DropdownMenuItem(value: value, child: Text(DateFormat('MMMM yyyy').format(d)));
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.month.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _attendanceForm(ReportsScreenController controller) {
    return Row(
      children: [
        Expanded(
          child: _dateField(
            label: AppString.startDate.tr,
            date: controller.startDate,
            onSelected: (d) => controller.startDate.value = d,
          ),
        ),
        Gap(width: AppSize.width(value: 12)),
        Expanded(
          child: _dateField(
            label: AppString.endDate.tr,
            date: controller.endDate,
            onSelected: (d) => controller.endDate.value = d,
          ),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required Rx<DateTime> date,
    required ValueChanged<DateTime> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: label, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black500),
        Gap(height: AppSize.height(value: 8)),
        GestureDetector(
          onTap: () => _showDatePickerDialog(date.value, onSelected),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black100),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(DateFormat('dd.MM.yyyy').format(date.value), style: TextStyle(fontSize: 14, color: AppColors.black400))),
                Icon(Icons.keyboard_arrow_down, color: AppColors.black400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Same SfDateRangePicker-in-a-dialog pattern already used in leave_screen.dart.
  void _showDatePickerDialog(DateTime initial, ValueChanged<DateTime> onSelected) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: EdgeInsets.zero,
            backgroundColor: AppColors.white100,
            content: Container(
              width: AppSize.width(value: 300),
              padding: const EdgeInsets.all(20),
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.single,
                view: DateRangePickerView.month,
                initialSelectedDate: initial,
                onSelectionChanged: (args) {
                  if (args.value is DateTime) {
                    onSelected(args.value as DateTime);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _formatAndLanguageRow(ReportsScreenController controller) {
    return Row(
      children: [
        Expanded(
          child: _dropdown<String>(
            value: controller.format,
            items: const {'pdf': 'PDF', 'excel': 'Excel'},
          ),
        ),
        Gap(width: AppSize.width(value: 12)),
        Expanded(
          child: _dropdown<String>(
            value: controller.lang,
            items: const {'en': 'English', 'de': 'Deutsch'},
          ),
        ),
      ],
    );
  }

  Widget _dropdown<T>({required Rx<String> value, required Map<String, String> items}) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black100),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value.value,
            items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) {
              if (v != null) value.value = v;
            },
          ),
        ),
      ),
    );
  }

  Widget _resultSection(ReportsScreenController controller) {
    switch (controller.state.value) {
      case ReportGenerationState.idle:
        return const SizedBox.shrink();
      case ReportGenerationState.generating:
        return Center(
          child: Column(
            children: [
              LoadingAnimationWidget.fourRotatingDots(color: AppColors.blue500, size: 40),
              Gap(height: AppSize.height(value: 12)),
              AppText(text: AppString.reportGenerating.tr, color: Colors.grey[600]),
            ],
          ),
        );
      case ReportGenerationState.error:
        return Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              Gap(height: AppSize.height(value: 8)),
              AppText(
                text: controller.errorMessage.value.isNotEmpty
                    ? controller.errorMessage.value
                    : AppString.reportGenerationFailed.tr,
                textAlign: TextAlign.center,
                color: Colors.grey[700],
              ),
              Gap(height: AppSize.height(value: 12)),
              AppButton(
                height: AppSize.height(value: 40),
                title: 'Retry',
                titleColor: AppColors.blue500,
                borderColor: AppColors.blue500,
                backgroundColor: AppColors.white200,
                onTap: controller.generateReport,
              ),
            ],
          ),
        );
      case ReportGenerationState.empty:
        return Center(
          child: Column(
            children: [
              Icon(Icons.description_outlined, size: 48, color: AppColors.black300),
              Gap(height: AppSize.height(value: 8)),
              AppText(text: AppString.reportEmptyState.tr, color: Colors.grey[600]),
            ],
          ),
        );
      case ReportGenerationState.ready:
        return Container(
          padding: EdgeInsets.all(AppSize.width(value: 16)),
          decoration: BoxDecoration(
            color: AppColors.blue50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.description, color: AppColors.blue500),
                  Gap(width: AppSize.width(value: 8)),
                  Expanded(
                    child: AppText(
                      text: controller.lastFileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.black500,
                    ),
                  ),
                ],
              ),
              Gap(height: AppSize.height(value: 12)),
              Row(
                children: [
                  if (controller.format.value == 'pdf') ...[
                    Expanded(
                      child: AppButton(
                        height: AppSize.height(value: 40),
                        title: AppString.viewReport.tr,
                        titleColor: AppColors.white100,
                        backgroundColor: AppColors.blue500,
                        onTap: () {
                          Get.to(
                            () => ReportPdfViewerScreen(
                              bytes: controller.lastReportBytes!,
                              fileName: controller.lastFileName,
                            ),
                          );
                        },
                      ),
                    ),
                    Gap(width: AppSize.width(value: 8)),
                  ],
                  Expanded(
                    child: AppButton(
                      height: AppSize.height(value: 40),
                      title: AppString.downloadReport.tr,
                      titleColor: AppColors.blue500,
                      borderColor: AppColors.blue500,
                      backgroundColor: AppColors.white100,
                      onTap: controller.downloadReport,
                    ),
                  ),
                  Gap(width: AppSize.width(value: 8)),
                  Expanded(
                    child: AppButton(
                      height: AppSize.height(value: 40),
                      title: AppString.shareReport.tr,
                      titleColor: AppColors.blue500,
                      borderColor: AppColors.blue500,
                      backgroundColor: AppColors.white100,
                      onTap: controller.shareReport,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }
}
