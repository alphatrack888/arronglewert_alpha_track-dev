import 'package:alpha_track/screens/profile_screen/gallery_screen/controller/gallery_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_images/app_images.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/widgets/ds/ds_bottom_sheet.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:alpha_track/widgets/ds/ds_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GalleryScreenController controller =
        Get.find<GalleryScreenController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Obx(() => _buildHeader(controller)),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return _buildLoadingWidget();
                    }

                    if (controller.isGalleryEmpty) {
                      return _buildEmptyGallery(controller);
                    }

                    return _buildGalleryContent(controller);
                  }),
                ),
              ],
            ),
          ),
          Obx(() {
            if (!controller.isUploading.value) {
              return const SizedBox.shrink();
            }
            return _buildUploadOverlay();
          }),
        ],
      ),
      floatingActionButton: Obx(() {
        final uploading = controller.isUploading.value;
        return FloatingActionButton(
          onPressed: uploading ? null : controller.showImagePicker,
          backgroundColor: AppColors.primary,
          child: uploading
              ? LoadingAnimationWidget.beat(
                  size: 24,
                  color: AppColors.white50,
                )
              : const Icon(
                  Icons.add_a_photo,
                  color: AppColors.white50,
                ),
        );
      }),
    );
  }

  /// Round 40x40 white circle icon button used in the header.
  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  /// Header: back + title + upload (image picker) action.
  Widget _buildHeader(GalleryScreenController controller) {
    final actionsEnabled = !controller.isUploading.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const DsBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(AppString.gallery.tr, style: AppTextStyles.headline),
          ),
          Opacity(
            opacity: actionsEnabled ? 1 : 0.4,
            child: _circleIconButton(
              icon: Icons.ios_share,
              onTap: actionsEnabled ? controller.showImagePicker : () {},
            ),
          ),
        ],
      ),
    );
  }

  /// Blocks interaction and shows upload progress over the gallery.
  Widget _buildUploadOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.35),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.beat(
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'uploadingImage'.tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.beat(size: 24, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            AppString.loadingGallery.tr,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  /// Build empty gallery widget
  Widget _buildEmptyGallery(GalleryScreenController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppString.noImagesYet.tr,
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 8),
            Text(
              AppString.startBuildingGallery.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 28),
            Obx(
              () => PrimaryButton(
                label: AppString.addImage.tr,
                onTap: controller.isUploading.value
                    ? () {}
                    : controller.showImagePicker,
                icon: Icons.add_a_photo,
                isTranslate: false,
                width: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build gallery content with images
  Widget _buildGalleryContent(GalleryScreenController controller) {
    final actionsEnabled = !controller.isUploading.value;
    return RefreshIndicator(
      onRefresh: controller.isUploading.value
          ? () async {}
          : controller.refreshGallery,
      color: AppColors.primary,
      child: Column(
        children: [
          // Eyebrow row: image count + quick actions.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${controller.totalImages} ${AppString.images.tr}"
                      .toUpperCase(),
                  style: AppTextStyles.eyebrow,
                ),
                Opacity(
                  opacity: actionsEnabled ? 1 : 0.4,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: actionsEnabled ? controller.pickFromCamera : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            actionsEnabled ? controller.pickFromGallery : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.photo_library_outlined,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            actionsEnabled ? controller.refreshGallery : null,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.refresh,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Gallery grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1,
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

  /// Build individual rounded image thumbnail.
  Widget _buildImageCard(
    GalleryScreenController controller,
    dynamic image,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _showImageSheet(image),
      onLongPress: () => _showImageOptions(controller, image),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: AppColors.fill,
          child: AppImage(
            url: image.image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  String _fileName(dynamic image) {
    final url = (image.image ?? '').toString();
    final seg = url.split('/').last;
    return (seg.isNotEmpty && seg.contains('.'))
        ? seg
        : 'image_${image.id ?? ''}.jpeg';
  }

  /// Image detail bottom sheet (matches Figma 109-3344).
  void _showImageSheet(dynamic image) {
    DsBottomSheet.show(
      DsBottomSheet(
        title: _fileName(image),
        trailing: GestureDetector(
          onTap: Get.back,
          child: Text('Close',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.danger)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppImage(
                  url: image.image,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              _sheetMeta(LucideIcons.folder, 'Project', 'Garden Cleaner',
                  underline: true),
              _sheetMeta(LucideIcons.calendar, 'Uploaded', 'March 12, 2025'),
              _sheetMeta(LucideIcons.hardDrive, 'Size', '12 MB'),
              const SizedBox(height: 16),
              SecondaryButton(
                label: 'Download',
                isTranslate: false,
                icon: LucideIcons.download,
                onTap: () {
                  Get.back();
                  AppSnackBar.message('imageDownloadSoon'.tr);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetMeta(IconData icon, String label, String value,
      {bool underline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(label,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.bodySemibold.copyWith(
                decoration: underline ? TextDecoration.underline : null,
              )),
        ],
      ),
    );
  }

  /// Show image options (delete, share, etc.)
  void _showImageOptions(GalleryScreenController controller, dynamic image) {
    DsBottomSheet.show(
      DsBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsSheetAction(
              icon: LucideIcons.trash2,
              label: AppString.deleteImage.tr,
              isDestructive: true,
              onTap: () async {
                Get.back();
                final confirmed = await DsDialog.confirm(
                  title: 'deleteImageQ'.tr,
                  message: 'deleteImageBody'.tr,
                  confirmLabel: 'Delete',
                  cancelLabel: 'Cancel',
                );
                if (confirmed && image.id != null) {
                  controller.deleteImage(image.id!);
                }
              },
            ),
            DsSheetAction(
              icon: LucideIcons.share2,
              label: AppString.shareImage.tr,
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
