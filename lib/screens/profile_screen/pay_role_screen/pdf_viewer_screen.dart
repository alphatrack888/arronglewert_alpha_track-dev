import 'package:alpha_track/screens/profile_screen/pay_role_screen/controller/payrole_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final PayroleScreenController controller =
        Get.find<PayroleScreenController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: filename + red Close.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  const DsBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      style: AppTextStyles.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => dsPop(context),
                    child: Text(
                      "Close",
                      style: AppTextStyles.bodySemibold.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.hasPdfError.value) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.fill,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.fileText,
                                  size: 72,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Text(
                                    controller.pdfErrorMessage.value.isNotEmpty
                                        ? controller.pdfErrorMessage.value
                                        : 'previewUnavailable'.tr,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: "Retry",
                                isTranslate: false,
                                onTap: () => controller.retryPdfLoad(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PrimaryButton(
                                label: "Download",
                                isTranslate: false,
                                icon: LucideIcons.download,
                                onTap: () => controller.downloadPdf(
                                  pdfUrl,
                                  fileName,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    SfPdfViewer.network(
                      pdfUrl,
                      controller: controller.pdfViewerController,
                      onDocumentLoaded: controller.onPdfDocumentLoaded,
                      onDocumentLoadFailed: controller.onPdfDocumentLoadFailed,
                    ),
                    if (controller.isPdfLoading.value)
                      Container(
                        color: AppColors.background.withValues(alpha: 0.85),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LoadingAnimationWidget.beat(
                                size: 24,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'loadingPdf'.tr,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
