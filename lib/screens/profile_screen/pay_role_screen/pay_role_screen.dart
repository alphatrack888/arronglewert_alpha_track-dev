import 'package:alpha_track/screens/profile_screen/pay_role_screen/controller/payrole_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PayRoleScreen extends StatelessWidget {
  const PayRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayroleScreenController>();
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.payRole,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: AppColors.blue500,
              size: 50,
            ),
          );
        }

        final payrollData = controller.payrollData.value;
        if (payrollData == null ||
            payrollData.data == null ||
            payrollData.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: AppColors.black300,
                ),
                Gap(height: AppSize.height(value: 16)),
                AppText(
                  text: AppString.noPayrollFilesAvailable.tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black300,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
          child: Column(
            children: [
              Gap(height: AppSize.height(value: 20)),
              ...payrollData.data!.expand((datum) {
                return datum.files?.map((fileUrl) {
                      final fileName = fileUrl.split('/').last;
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSize.width(value: 09),
                          vertical: AppSize.height(value: 09),
                        ),
                        height: AppSize.height(value: 50),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.blue50,
                          borderRadius: BorderRadius.circular(06),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.pdfIcons,
                              height: AppSize.height(value: 25),
                              width: AppSize.width(value: 25),
                            ),
                            Gap(width: AppSize.width(value: 10)),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    controller.viewPdf(fileUrl, fileName),
                                child: AppText(
                                  text: fileName.isNotEmpty
                                      ? fileName
                                      : AppString.pdfFile,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black500,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Gap(width: AppSize.width(value: 10)),
                            // View button
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () =>
                                  controller.viewPdf(fileUrl, fileName),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.visibility_outlined,
                                  color: AppColors.blue500,
                                  size: 20,
                                ),
                              ),
                            ),
                            Gap(width: AppSize.width(value: 5)),
                            Obx(
                              () => InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: controller.isFileDownloading(fileUrl)
                                    ? null
                                    : () => controller.downloadPdf(
                                        fileUrl,
                                        fileName,
                                      ),
                                child: controller.isFileDownloading(fileUrl)
                                    ? LoadingAnimationWidget.beat(
                                        size: 24,
                                        color: Colors.white,
                                      )
                                    : SvgPicture.asset(AppIcons.downloadIcon),
                              ),
                            ),
                            Gap(width: AppSize.width(value: 5)),
                            // External open button
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () =>
                                  controller.openPdfExternally(fileUrl),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.open_in_new,
                                  color: AppColors.blue500,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList() ??
                    [];
              }).toList(),
              Gap(height: AppSize.height(value: 20)),
            ],
          ),
        );
      }),
    );
  }
}
