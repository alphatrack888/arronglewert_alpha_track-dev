import 'dart:ui';
import 'package:alpha_track/screens/break_screen/leave_screen/controller/leave_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatelessWidget {
  // Changed to StatelessWidget
  LeaveScreen({super.key});

  final LeaveScreenController controller = Get.find<LeaveScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white200,
      appBar: AuthAppBar(
        title: AppString.leave,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(height: 25),
              // Leave Type and Leave Consume Type Row
              _buildDropdownField(
                label: AppString.leaveType.tr,
                items: controller.leaveTypes,
                selectedValue: controller.selectedLeaveType,
                onChanged: controller.updateLeaveType,
              ),

              Gap(height: 20),

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
                  Gap(width: 16),
                  Expanded(
                    child: _buildDateField(
                      label: AppString.todate.tr,
                      selectedDate: controller.toDate,
                      onDateSelected: controller.updateToDate,
                    ),
                  ),
                ],
              ),

              Gap(height: 20),
              // Leave Duration Display
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.blue500),
                  ),
                  child: AppText(
                    text:
                        '${AppString.leaveDuration.tr}: ${controller.leaveDuration} ${AppString.days.tr}',
                    color: AppColors.blue500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Gap(height: 20),
              // Reason Field
              _buildReasonField(),
              Gap(height: 32),
              // Submit Button
              AppButton(
                title:
                    '${AppString.applyFor.tr} ${controller.leaveDuration} ${AppString.dayLeave.tr}',
                onTap: controller.submitLeaveApplication,
                titleColor: AppColors.blue500,
                backgroundColor: AppColors.blue50,
              ),
            ],
          ),
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
          color: AppColors.black300,
        ),
        Gap(height: 08),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Gap(height: 8),
        GestureDetector(
          onTap: () =>
              _showDatePicker(Get.context!, selectedDate, onDateSelected),
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
                Obx(
                  () => Text(
                    DateFormat('dd.MM.yyyy').format(selectedDate.value),
                    style: TextStyle(fontSize: 14, color: AppColors.black400),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColors.black400),
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
          color: AppColors.black500,
        ),
        Gap(height: AppSize.height(value: 08)),
        CustomTextField(
          backgroundColor: AppColors.white100,
          borderColor: AppColors.black100,
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
                  Gap(height: AppSize.height(value: 08)),
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
