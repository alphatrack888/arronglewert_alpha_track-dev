import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/app_images/app_images.dart';

class ImagePreviewScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const ImagePreviewScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: initialIndex);
    RxInt currentIndex = initialIndex.obs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Title (filename) + red Close.
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final url = images[currentIndex.value];
                      final fileName = url.split('/').last;
                      return Text(
                        fileName.isNotEmpty ? fileName : "Image",
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      "Close",
                      style: AppTextStyles.bodySemibold.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Large rounded image (swipeable).
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (index) => currentIndex.value = index,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        child: Container(
                          color: AppColors.fill,
                          alignment: Alignment.center,
                          child: AppImage(
                            url: images[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Page counter row.
              Center(
                child: Obx(
                  () => Text(
                    "${currentIndex.value + 1} of ${images.length}",
                    style: AppTextStyles.caption,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
