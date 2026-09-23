import 'package:alpha_track/screens/profile_screen/gallery_screen/controller/gallery_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_images/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GalleryScreenController controller =
        Get.find<GalleryScreenController>();

    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.gallery,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingWidget();
        }

        if (controller.isGalleryEmpty) {
          return _buildEmptyGallery(controller);
        }

        return _buildGalleryContent(controller);
      }),
      floatingActionButton: Obx(() {
        return controller.isUploading.value
            ? FloatingActionButton(
                onPressed: null,
                backgroundColor: AppColors.blue50,
                child: LoadingAnimationWidget.beat(
                  size: 24,
                  color: Colors.white,
                ),
              )
            : FloatingActionButton(
                onPressed: controller.showImagePicker,
                backgroundColor: AppColors.blue500,
                child: const Icon(Icons.add_a_photo, color: Colors.white),
              );
      }),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.beat(size: 24, color: Colors.grey),
          Gap(height: AppSize.height(value: 16)),
          Text(
            AppString.loadingGallery.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Build empty gallery widget
  Widget _buildEmptyGallery(GalleryScreenController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.blue50,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 60,
              color: AppColors.blue500,
            ),
          ),
          Gap(height: AppSize.height(value: 24)),
          Text(
            AppString.noImagesYet.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Gap(height: AppSize.height(value: 8)),
          Text(
            AppString.startBuildingGallery.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Gap(height: AppSize.height(value: 32)),
          ElevatedButton.icon(
            onPressed: controller.showImagePicker,
            icon: const Icon(Icons.add_a_photo),
            label: Text(AppString.addImage.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue500,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.width(value: 24),
                vertical: AppSize.height(value: 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build gallery content with images
  Widget _buildGalleryContent(GalleryScreenController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshGallery,
      child: Column(
        children: [
          // Header with image count and quick actions
          Padding(
            padding: EdgeInsets.all(AppSize.width(value: 20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${controller.totalImages} ${AppString.images.tr}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    // Quick camera button
                    GestureDetector(
                      onTap: controller.pickFromCamera,
                      child: Container(
                        padding: EdgeInsets.all(AppSize.width(value: 8)),
                        margin: EdgeInsets.only(right: AppSize.width(value: 8)),
                        decoration: BoxDecoration(
                          color: AppColors.blue50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: AppColors.blue500,
                        ),
                      ),
                    ),
                    // Quick gallery button
                    GestureDetector(
                      onTap: controller.pickFromGallery,
                      child: Container(
                        padding: EdgeInsets.all(AppSize.width(value: 8)),
                        margin: EdgeInsets.only(right: AppSize.width(value: 8)),
                        decoration: BoxDecoration(
                          color: AppColors.blue50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.photo_library,
                          size: 20,
                          color: AppColors.blue500,
                        ),
                      ),
                    ),
                    // Refresh button
                    GestureDetector(
                      onTap: controller.refreshGallery,
                      child: Container(
                        padding: EdgeInsets.all(AppSize.width(value: 8)),
                        decoration: BoxDecoration(
                          color: AppColors.blue50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 20,
                          color: AppColors.blue500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Gallery grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.width(value: 20),
              ),
              child: GridView.builder(
                padding: EdgeInsets.only(bottom: AppSize.height(value: 80)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSize.width(value: 12),
                  mainAxisSpacing: AppSize.height(value: 12),
                  childAspectRatio: 0.75,
                ),
                itemCount: controller.galleryImages.length,
                itemBuilder: (context, index) {
                  final image = controller.galleryImages[index];
                  return _buildImageCard(controller, image, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual image card
  Widget _buildImageCard(
    GalleryScreenController controller,
    dynamic image,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _showImagePreview(controller, index),
      onLongPress: () => _showImageOptions(controller, image),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: AppImage(
                  url: image.image,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Info section
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.width(value: 12),
                  vertical: AppSize.height(value: 8),
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${AppString.image.tr} ${index + 1}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.more_vert, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show image preview in full screen
  void _showImagePreview(GalleryScreenController controller, int initialIndex) {
    Get.to(
      () => GalleryPreviewScreen(
        images: controller.galleryImages,
        initialIndex: initialIndex,
      ),
    );
  }

  /// Show image options (delete, share, etc.)
  void _showImageOptions(GalleryScreenController controller, dynamic image) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(AppString.deleteImage.tr),
              onTap: () {
                Get.back();
                if (image.id != null) {
                  controller.deleteImage(image.id!);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: Text(AppString.shareImage.tr),
              onTap: () {
                Get.back();
                // Implement share functionality
                Get.snackbar(
                  AppString.info.tr,
                  AppString.shareFeatureComingSoon.tr,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Full screen image preview
class GalleryPreviewScreen extends StatelessWidget {
  final List images;
  final int initialIndex;

  const GalleryPreviewScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: initialIndex);
    RxInt currentIndex = initialIndex.obs;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            "${currentIndex.value + 1} ${AppString.of.tr} ${images.length}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                AppString.info.tr,
                AppString.shareFeatureComingSoon.tr,
              );
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: pageController,
        onPageChanged: (index) => currentIndex.value = index,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: AppImage(
                url: images[index].image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
