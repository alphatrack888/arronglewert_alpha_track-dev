import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'dart:developer';

import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class ProjectNotesScreenController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final ImagePickerService _picker = ImagePickerService();
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxList<XFile> selectedImages = <XFile>[].obs;

  void sendMessage() {
    if (textController.text.isNotEmpty) {
      messages.add({
        'text': textController.text,
        'isSentByMe': true,
        'timestamp': DateTime.now(),
        'type': 'text',
      });
      textController.clear();
    }
  }

  String formatTime(DateTime time) {
    return "${time.hour}:${time.minute} ${time.hour >= 12 ? 'PM' : 'AM'}";
  }

  Future<void> sendPhoto() async {
    try {
      final List<XFile> images = await _picker.pickMultipleImages();
      if (images.isNotEmpty) {
        selectedImages.assignAll(images);
        showSelectedImages();
      }
    } catch (e) {
      log('Error picking images: $e');
      AppSnackBar.error(ImagePickerService.errorMessage(e));
    }
  }

  void showSelectedImages() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => AppText(
                        text: 'Selected Images (${selectedImages.length})',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      )),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          selectedImages.clear();
                          Get.back();
                        },
                        child: AppText(text: "Cancel",fontSize: 18,fontWeight: FontWeight.w500,color: AppColors.black500,)),
                      
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          sendSelectedImages();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue500,
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() => GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(selectedImages[index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void sendSelectedImages() {
    if (selectedImages.isNotEmpty) {
      messages.add({
        'images': selectedImages.map((img) => img.path).toList(),
        'isSentByMe': true,
        'timestamp': DateTime.now(),
        'type': 'images',
      });
      selectedImages.clear();
    }
  }
}