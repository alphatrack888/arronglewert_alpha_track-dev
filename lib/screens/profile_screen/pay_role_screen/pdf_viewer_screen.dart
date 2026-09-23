import 'package:alpha_track/screens/profile_screen/pay_role_screen/controller/payrole_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
      appBar: AuthAppBar(
        title: fileName,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      body: Obx(() {
        if (controller.hasPdfError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const Gap(height: 16),
                  AppText(
                    text: 'Failed to load PDF',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const Gap(height: 8),
                  AppText(
                    text: controller.pdfErrorMessage.value.isNotEmpty
                        ? controller.pdfErrorMessage.value
                        : 'Unable to load the PDF document',
                    textAlign: TextAlign.center,
                    color: Colors.grey,
                  ),

                  const Gap(height: 8),
                  AppText(
                    text: 'URL: $pdfUrl',
                    textAlign: TextAlign.center,
                    fontSize: 12,
                    color: Colors.grey,
                  ),

                  const Gap(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        onTap: () {
                          controller.retryPdfLoad();
                        },
                        title: "Retry",
                        titleColor: AppColors.blue500,
                        borderColor: AppColors.blue500,
                        backgroundColor: AppColors.white200,
                      ),
                      const SizedBox(width: 16),
                      AppButton(
                        onTap: () => Get.back(),
                        title: "Go Back",
                        titleColor: AppColors.blue500,
                        borderColor: AppColors.blue500,
                        backgroundColor: AppColors.white200,
                      ),
                    ],
                  ),
                ],
              ),
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
                color: Colors.white.withValues(alpha: 0.8),
                child:  Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.beat(size: 24, color: Colors.grey,),
                      const Gap(height: 16),
                      Text('Loading PDF...', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
