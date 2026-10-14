import 'package:alpha_track/screens/profile_screen/pay_role_screen/controller/payrole_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';

class PayRoleScreen extends StatelessWidget {
  const PayRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayroleScreenController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: AppColors.primary,
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
                        const Icon(
                          LucideIcons.fileText,
                          size: 64,
                          color: AppColors.textFaint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppString.noPayrollFilesAvailable.tr,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Eyebrow row.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("INVOICES", style: AppTextStyles.eyebrow),
                          Text(
                            '${'sortBy'.tr}: ${'newest'.tr}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...payrollData.data!.expand((datum) {
                        return datum.files?.map((fileUrl) {
                              final fileName = fileUrl.split('/').last;
                              return _buildInvoiceRow(
                                controller,
                                fileUrl,
                                fileName,
                              );
                            }).toList() ??
                            [];
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const DsBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(AppString.payRole.tr, style: AppTextStyles.headline),
          ),
        ],
      ),
    );
  }


  /// Invoice card row: PDF icon tile, file name + actions, amount/actions right.
  Widget _buildInvoiceRow(
    PayroleScreenController controller,
    String fileUrl,
    String fileName,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DsCard(
        onTap: () => controller.viewPdf(fileUrl, fileName),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // PDF icon tile.
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                AppIcons.pdfIcons,
                height: 24,
                width: 24,
              ),
            ),
            const SizedBox(width: 12),
            // File name.
            Expanded(
              child: Text(
                fileName.isNotEmpty ? fileName : AppString.pdfFile.tr,
                style: AppTextStyles.bodySemibold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // View button.
            _actionIcon(
              icon: LucideIcons.eye,
              onTap: () => controller.viewPdf(fileUrl, fileName),
            ),
            // Download button.
            Obx(
              () => GestureDetector(
                onTap: controller.isFileDownloading(fileUrl)
                    ? null
                    : () => controller.downloadPdf(fileUrl, fileName),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: controller.isFileDownloading(fileUrl)
                      ? LoadingAnimationWidget.beat(
                          size: 20,
                          color: AppColors.primary,
                        )
                      : Icon(
                          LucideIcons.download,
                          size: 20,
                          color: AppColors.primary,
                        ),
                ),
              ),
            ),
            // External open button.
            _actionIcon(
              icon: LucideIcons.externalLink,
              size: 18,
              onTap: () => controller.openPdfExternally(fileUrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required VoidCallback onTap,
    double size = 20,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, size: size, color: AppColors.primary),
      ),
    );
  }
}
