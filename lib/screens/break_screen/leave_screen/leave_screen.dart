import 'dart:ui';
import 'package:alpha_track/screens/break_screen/leave_screen/controller/leave_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';

class LeaveScreen extends StatelessWidget {
  // Changed to StatelessWidget
  LeaveScreen({super.key});

  final LeaveScreenController controller = Get.find<LeaveScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: back + title.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  const DsBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'leaveSchedule'.tr,
                      style: AppTextStyles.headline,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Leave Type
                      _buildDropdownField(
                        label: AppString.leaveType.tr,
                        items: controller.leaveTypes,
                        selectedValue: controller.selectedLeaveType,
                        onChanged: controller.updateLeaveType,
                      ),

                      const SizedBox(height: 20),

                      // From Date and To Date Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: AppString.fromDate.tr,
                              selectedDate: controller.fromDate,
                              onDateSelected: controller.updateFromDate,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              label: AppString.todate.tr,
                              selectedDate: controller.toDate,
                              onDateSelected: controller.updateToDate,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      // Leave Duration Display
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppText(
                            text:
                                '${AppString.leaveDuration.tr}: ${controller.leaveDuration} ${AppString.days.tr}',
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Reason Field
                      _buildReasonField(),
                      const SizedBox(height: 32),
                      // Submit Button
                      Obx(
                        () => PrimaryButton(
                          label:
                              '${AppString.applyFor.tr} ${controller.leaveDuration} ${AppString.dayLeave.tr}',
                          isTranslate: false,
                          // TEST MODE: skip backend submit; confirm and go back.
                          // For production, restore: controller.submitLeaveApplication
                          onTap: () {
                            Get.back();
                            Get.snackbar('leaveApplied'.tr,
                                'leaveSubmittedTest'.tr,
                                snackPosition: SnackPosition.BOTTOM);
                          },
                          isLoading: controller.isLoading.value,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required RxString selectedValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: AppSize.width(value: 14),
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.stroke),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surface,
            ),
            child: DropdownButtonFormField<String>(
              value: selectedValue.value.isEmpty ? null : selectedValue.value,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.black400),
              decoration: InputDecoration(
                fillColor: Colors.white, // Changed from AppColors.white200
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide
                      .none, // Remove the border since container has it
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              dropdownColor: Colors
                  .white, // Add this to ensure dropdown background is white
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    width: double.infinity, // Add this to ensure full width
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: AppText(
                      text: item.tr,
                      fontSize: AppSize.width(value: 14),
                      fontWeight: FontWeight.w400,
                      color: AppColors.black400,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  onChanged(value);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '${AppString.pleaseSelect.tr} $label';
                }
                return null;
              },
              isExpanded: true, // Add this to make dropdown take full width
              isDense: false, // Ensure proper spacing
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required Rx<DateTime> selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () =>
              _showDatePicker(Get.context!, selectedDate, onDateSelected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.stroke),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    DateFormat('dd.MM.yyyy').format(selectedDate.value),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: AppString.leaveReason.tr,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          backgroundColor: AppColors.surface,
          borderColor: AppColors.stroke,
          hintText: AppString.typeHere.tr,
          maxLines: 5,
          height: AppSize.height(value: 48),
          controller: controller.reasonController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppString.pleaseEnterReasonForLeave.tr;
            }
            if (value.trim().length < 10) {
              return AppString.reasonMinLength10.tr;
            }
            return null;
          },
        ),
      ],
    );
  }

  void _showDatePicker(
    BuildContext context,
    Rx<DateTime> selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.zero,
            backgroundColor: AppColors.white100,
            content: Container(
              width: AppSize.width(value: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.white100,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: AppString.selectDate.tr,
                    fontSize: AppSize.height(value: 16),
                    fontWeight: FontWeight.w500,
                    color: AppColors.black500,
                  ),
                  const SizedBox(height: 8),
                  SfDateRangePicker(
                    selectionMode: DateRangePickerSelectionMode.single,
                    view: DateRangePickerView.month,
                    selectionColor: AppColors.black500,
                    initialSelectedDate: selectedDate.value,
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                          if (args.value != null) {
                            onDateSelected(args.value as DateTime);
                            Navigator.of(context).pop();
                          }
                        },
                    startRangeSelectionColor: AppColors.black500,
                    endRangeSelectionColor: AppColors.black500,
                    rangeSelectionColor: AppColors.white800,
                    backgroundColor: AppColors.white100,
                    selectionShape: DateRangePickerSelectionShape.circle,
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: AppColors.white100,
                      textStyle: TextStyle(
                        color: AppColors.black500,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
