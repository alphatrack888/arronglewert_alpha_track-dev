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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            "${currentIndex.value + 1} of ${images.length}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Get.snackbar("Info", "Share feature coming soon!");
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
                url: images[index],
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