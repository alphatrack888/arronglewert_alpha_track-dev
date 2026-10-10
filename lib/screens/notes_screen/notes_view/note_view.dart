import 'dart:io';
import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/screens/notes_screen/note_screen/controller/notes_screen_controller.dart';
import 'package:alpha_track/screens/notes_screen/notes_view/controller/note_veiw_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_button/app_icon_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:alpha_track/widgets/app_audio_player/enhanced_audio_player.dart';
import 'package:alpha_track/widgets/image_preview_widget/image_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NoteView extends StatelessWidget {
  const NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the GetX controller
    final NoteVeiwController controller = Get.find<NoteVeiwController>();
    final NotesScreenController notesScreenController =
        Get.find<NotesScreenController>();

    // Fix: Use proper ever syntax with a callback function
    ever(notesScreenController.selectedImages, (selectedImages) {
      if (selectedImages.isNotEmpty) {
        _showSelectedImagesUI(notesScreenController);
      }
    });

    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.typeNote.tr,
        showLeading: true,
        showAction: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(15.0),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final note = controller.messages[index];
                        return _buildNoteCard(note, index, controller);
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteOptions(controller, notesScreenController),
        backgroundColor: AppColors.blue500,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add, size: 64, color: Colors.grey[400]),
          const Gap(height: 16),
          AppText(
            text: AppString.noNotesYet.tr,
            fontSize: AppSize.width(value: 18),
            color: AppColors.white900,
            fontWeight: FontWeight.w500,
          ),
          const Gap(height: 8),
          AppText(
            text: AppString.tapPlusToCreateFirstNote.tr,
            fontSize: AppSize.width(value: 14),
            color: AppColors.white900,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    // Check if it's a network URL or local file path
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network image from API
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, color: Colors.grey);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // Local file image
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, color: Colors.grey);
        },
      );
    }
  }

  Widget _buildNoteCard(
    Map<String, dynamic> note,
    int index,
    NoteVeiwController controller,
  ) {
    appLog('Note data: $note');
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => _showNoteDetails(note, index, controller),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with timestamp and creator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getNoteIcon(note),
                        size: 16,
                        color: AppColors.blue500,
                      ),
                      const Gap(width: 4),
                      AppText(
                        text: note['createdBy'] ?? AppString.unknownUser.tr,
                        fontSize: AppSize.width(value: 14),
                        color: AppColors.blue500,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  Text(
                    controller.formatTime(note['timestamp'] ?? DateTime.now()),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const Gap(height: 12),

              // Content Section - Show text content if available
              if (_hasTextContent(note)) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.text_fields,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const Gap(width: 4),
                          AppText(
                            text: AppString.textContent.tr,
                            fontSize: AppSize.width(value: 12),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      const Gap(height: 6),
                      AppText(
                        text: _getTextContent(note),
                        fontSize: AppSize.width(value: 14),
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Gap(height: 8),
              ],
              // Images Section - Show images if available
              if (_hasImages(note)) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.image,
                            color: Colors.blue.shade600,
                            size: 16,
                          ),
                          const Gap(width: 4),
                          AppText(
                            text:
                                '${_getImagesCount(note)} ${AppString.images.tr}',
                            fontSize: AppSize.width(value: 12),
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      const Gap(height: 8),
                      // Show image grid for multiple images or single image
                      _buildImagePreview(note),
                    ],
                  ),
                ),
                const Gap(height: 8),
              ],
              // Audio Section - Show audio if available
              if (_hasAudio(note)) ...[
                EnhancedAudioPlayer(
                  audioPath: _getAudioPath(note),
                  audioTitle: _getAudioTitle(note),
                  duration: note['duration'] ?? '0:00',
                ),
                const Gap(height: 8),
              ],

              // Tap to view indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppText(
                    text: AppString.tapToViewDetails.tr,
                    fontSize: 12,
                    color: AppColors.blue500,
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.blue500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods to check content types
  bool _hasTextContent(Map<String, dynamic> note) {
    return (note['text'] != null &&
            note['text'].toString().trim().isNotEmpty) ||
        (note['content'] != null &&
            note['content'].toString().trim().isNotEmpty);
  }

  String _getTextContent(Map<String, dynamic> note) {
    return note['text']?.toString() ?? note['content']?.toString() ?? '';
  }

  bool _hasImages(Map<String, dynamic> note) {
    return note['images'] != null &&
        note['images'] is List &&
        (note['images'] as List).isNotEmpty;
  }

  int _getImagesCount(Map<String, dynamic> note) {
    if (!_hasImages(note)) return 0;
    return (note['images'] as List).length;
  }


  bool _hasAudio(Map<String, dynamic> note) {
    return (note['audio'] != null && note['audio'].toString().isNotEmpty) ||
        (note['type'] == 'audio' && note['path'] != null);
  }

  String _getAudioPath(Map<String, dynamic> note) {
    if (note['audio'] != null && note['audio'].toString().isNotEmpty) {
      return note['audio'].toString();
    }
    return note['path']?.toString() ?? '';
  }

  String _getAudioTitle(Map<String, dynamic> note) {
    // Try to get a meaningful title from the note
    if (note['audioTitle'] != null &&
        note['audioTitle'].toString().isNotEmpty) {
      return note['audioTitle'].toString();
    }

    // If there's text content, use first few words as title
    if (_hasTextContent(note)) {
      String textContent = _getTextContent(note);
      List<String> words = textContent.split(' ');
      if (words.length > 3) {
        return '${words.take(3).join(' ')}...';
      } else if (textContent.length > 20) {
        return '${textContent.substring(0, 20)}...';
      } else {
        return textContent;
      }
    }

    // Default title with timestamp
    DateTime timestamp = note['timestamp'] ?? DateTime.now();
    String timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return '${AppString.audioRecording.tr} - $timeStr';
  }

  int _getContentTypesCount(Map<String, dynamic> note) {
    int count = 0;
    if (_hasTextContent(note)) count++;
    if (_hasImages(note)) count++;
    if (_hasAudio(note)) count++;
    return count;
  }

  String _getContentSummary(Map<String, dynamic> note) {
    List<String> types = [];
    if (_hasTextContent(note)) types.add(AppString.textContent.tr);
    if (_hasImages(note)) {
      types.add(
        '${_getImagesCount(note)} ${AppString.images.tr}',
      );
    }
    if (_hasAudio(note)) types.add(AppString.audioRecording.tr);

    return types.join(' • ');
  }

  // Get appropriate icon based on note content
  IconData _getNoteIcon(Map<String, dynamic> note) {
    int contentTypes = _getContentTypesCount(note);

    if (contentTypes > 1) {
      return Icons.layers; // Mixed content
    } else if (_hasImages(note)) {
      return Icons.image;
    } else if (_hasAudio(note)) {
      return Icons.mic;
    } else {
      return Icons.note;
    }
  }

  // Build image preview widget
  Widget _buildImagePreview(Map<String, dynamic> note) {
    if (!_hasImages(note)) return const SizedBox.shrink();
    List images = note['images'] as List;
    if (images.length == 1) {
      // Single image preview
      return Container(
        height: AppSize.height(value: 80),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImageWidget(images.first?.toString() ?? ''),
        ),
      );
    } else {
      // Multiple images grid
      return SizedBox(
        height: AppSize.height(value: 60),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length > 4 ? 4 : images.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              width: AppSize.width(value: 60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _buildImageWidget(images[index]?.toString() ?? ''),
                  ),
                  if (index == 3 && images.length > 4)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: AppText(
                          text: '+${images.length - 4}',
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  void _showNoteOptions(
    NoteVeiwController controller,
    NotesScreenController notesScreenController,
  ) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                height: AppSize.height(value: 04),
                width: AppSize.width(value: 40),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: AppString.createNewNote.tr,
                    fontSize: AppSize.width(value: 20),
                    fontWeight: FontWeight.bold,
                  ),
                  const Gap(height: 10),
                  AppButtonWithIcon(
                    buttonText: AppString.mixedNote.tr,
                    svgIconPath: AppIcons.allNotes,
                    onPressed: () {
                      Get.back();
                      _showMixedNoteDialog(controller);
                    },
                    textColor: AppColors.blue700,
                  ),
                  const Gap(height: 16),
                  AppButtonWithIcon(
                    buttonText: AppString.textNote.tr,
                    svgIconPath: AppIcons.textNotes,
                    onPressed: () {
                      Get.back();
                      _showTextNoteDialog(controller);
                    },
                    textColor: AppColors.blue700,
                  ),
                  const Gap(height: 16),
                  AppButtonWithIcon(
                    buttonText: AppString.imageNote.tr,
                    svgIconPath: AppIcons.imageNotes,
                    onPressed: () {
                      Get.back();
                      notesScreenController.sendPhoto();
                    },
                    textColor: AppColors.blue700,
                  ),
                  const Gap(height: 16),
                  // Audio Note Option
                  AppButtonWithIcon(
                    buttonText: AppString.audioNote.tr,
                    svgIconPath: AppIcons.audioNote,
                    onPressed: () {
                      Get.back();
                      _showAdvancedAudioRecordingDialog(controller);
                    },
                    textColor: AppColors.blue700,
                  ),
                  const Gap(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  void _showMixedNoteDialog(NoteVeiwController controller) {
    controller.textController.clear();
    controller.selectedImages.clear();
    controller.resetRecordingState();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white50,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppString.createMixedNote.tr,
                    fontSize: AppSize.width(value: 18),
                    fontWeight: FontWeight.bold,
                  ),
                  const Gap(height: 16),

                  // Text Section
                  AppText(
                    text: AppString.textContentOptional.tr,
                    fontSize: AppSize.width(value: 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue500,
                  ),
                  const Gap(height: 8),
                  CustomTextField(
                    hintText: AppString.writeYourNoteHere.tr,
                    maxLines: 3,
                    controller: controller.textController,
                    backgroundColor: AppColors.blue50,
                  ),
                  const Gap(height: 16),

                  // Images Section
                  AppText(
                    text: AppString.imagesOptional.tr,
                    fontSize: AppSize.width(value: 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue500,
                  ),
                  const Gap(height: 8),
                  Obx(
                    () => controller.selectedImages.isNotEmpty
                        ? Container(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.selectedImages.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.blue200,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(
                                        controller.selectedImages[index].path,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.blue50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.blue200,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Center(
                              child: AppText(
                                text: AppString.noImagesSelected.tr,
                                color: AppColors.blue400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                  ),
                  const Gap(height: 8),
                  AppButton(
                    onTap: () async {
                      try {
                        final images =
                            await ImagePickerService().pickMultipleImages();
                        if (controller.isClosed) return;
                        if (images.isNotEmpty) {
                          controller.selectedImages.addAll(images);
                        }
                      } catch (error) {
                        if (!controller.isClosed) {
                          AppSnackBar.error(
                              ImagePickerService.errorMessage(error));
                        }
                      }
                    },
                    backgroundColor: AppColors.blue100,
                    title: AppString.addImages.tr,
                    titleColor: AppColors.blue500,
                    borderColor: AppColors.blue500,
                    width: double.infinity,
                    height: 35,
                  ),
                  const Gap(height: 16),

                  // Audio Section
                  AppText(
                    text: AppString.audioRecordingOptional.tr,
                    fontSize: AppSize.width(value: 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue500,
                  ),
                  const Gap(height: 8),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.blue200),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => controller.toggleRecording(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.isRecording.value
                                    ? Colors.red
                                    : AppColors.blue400,
                              ),
                              child: Icon(
                                controller.isRecording.value
                                    ? Icons.stop
                                    : Icons.mic,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const Gap(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: controller.isRecording.value
                                      ? AppString.recording.tr
                                      : controller.hasRecording.value
                                          ? AppString.recordingReady.tr
                                          : AppString.tapToRecord.tr,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                if (controller.hasRecording.value)
                                  AppText(
                                    text: controller.formattedDuration,
                                    fontSize: 10,
                                    color: AppColors.blue400,
                                  ),
                              ],
                            ),
                          ),
                          if (controller.hasRecording.value)
                            GestureDetector(
                              onTap: () => controller.togglePlayback(),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: controller.isPlaying.value
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                child: Icon(
                                  controller.isPlaying.value
                                      ? Icons.stop
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppButton(
                        onTap: () {
                          Get.back();
                        },
                        backgroundColor: AppColors.white100,
                        title: AppString.cancel.tr,
                        titleColor: AppColors.blue500,
                        borderColor: AppColors.blue500,
                        width: 100,
                        height: 40,
                      ),
                      Obx(
                        () => AppButton(
                          onTap: controller.isLoading.value
                              ? null
                              : () async {
                                  // Check if at least one content type is provided
                                  bool hasText =
                                      controller.textController.text.isNotEmpty;
                                  bool hasImages =
                                      controller.selectedImages.isNotEmpty;
                                  bool hasAudio = controller.hasRecording.value;

                                  if (!hasText && !hasImages && !hasAudio) {
                                    Get.snackbar(
                                      AppString.error.tr,
                                      AppString
                                          .pleaseAddAtLeastOneContentType.tr,
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  Get.back();
                                  await controller.createMixedNote(
                                    content: hasText
                                        ? controller.textController.text
                                        : null,
                                    images: hasImages
                                        ? controller.selectedImages
                                              .map((xFile) => File(xFile.path))
                                              .toList()
                                        : null,
                                    audio:
                                        hasAudio && controller.audioPath != null
                                        ? File(controller.audioPath!)
                                        : null,
                                  );
                                },
                          backgroundColor: controller.isLoading.value
                              ? AppColors.blue200
                              : AppColors.blue500,
                          title: controller.isLoading.value
                              ? AppString.creating.tr
                              : AppString.createNote.tr,
                          titleColor: AppColors.white100,
                          width: 120,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTextNoteDialog(NoteVeiwController controller) {
    controller.textController.clear();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white50,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: AppString.createTextNote.tr,
                fontSize: AppSize.width(value: 18),
                fontWeight: FontWeight.bold,
              ),
              const Gap(height: 16),
              CustomTextField(
                hintText: AppString.writeYourNoteHere.tr,
                maxLines: 5,
                controller: controller.textController,
                backgroundColor: AppColors.blue50,
              ),
              const Gap(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    onTap: () {
                      Get.back();
                    },
                    backgroundColor: AppColors.white100,
                    title: AppString.cancel.tr,
                    fontSize: AppSize.width(value: 12),
                    titleColor: AppColors.blue500,
                    borderColor: AppColors.blue500,
                    width: 100,
                    height: 40,
                  ),
                  AppButton(
                    onTap: () async {
                      Get.back();
                      await controller.sendMessage();
                    },
                    backgroundColor: AppColors.white100,
                    title: AppString.saveNote.tr,
                    fontSize: AppSize.width(value: 12),
                    titleColor: AppColors.blue500,
                    borderColor: AppColors.blue500,
                    width: 100,
                    height: 40,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdvancedAudioRecordingDialog(NoteVeiwController controller) {
    // Reset recording state
    controller.resetRecordingState();
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              AppText(
                text: AppString.recordAudioNote.tr,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const Gap(height: 8),
              AppText(
                text: AppString.tapMicToStartRecording.tr,
                fontSize: 14,
                color: Colors.grey[600],
                textAlign: TextAlign.center,
              ),
              const Gap(height: 24),

              // Recording button with animated circles
              Obx(
                () => GestureDetector(
                  onTap: () => controller.toggleRecording(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer animated circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: controller.isRecording.value ? 120 : 100,
                        height: controller.isRecording.value ? 120 : 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.blue500.withValues(alpha: 0.1),
                        ),
                      ),
                      // Middle circle
                      Container(
                        width: AppSize.width(value: 80),
                        height: AppSize.height(value: 80),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.blue500.withValues(alpha: 0.2),
                        ),
                      ),
                      // Inner circle with microphone
                      Container(
                        width: AppSize.width(value: 80),
                        height: AppSize.height(value: 60),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.isRecording.value
                              ? Colors.red
                              : AppColors.blue400,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: controller.isLoading.value
                            ? LoadingAnimationWidget.beat(
                                size: 24,
                                color: AppColors.blue500,
                              )
                            : Icon(
                                controller.isRecording.value
                                    ? Icons.stop
                                    : Icons.mic,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(height: 16),

              // Status text
              Obx(
                () => AppText(
                  text: controller.isLoading.value
                      ? AppString.processing.tr
                      : controller.isRecording.value
                          ? AppString.recordingTapToStop.tr
                          : controller.hasRecording.value
                              ? AppString.recordingComplete.tr
                              : AppString.tapToStartRecording.tr,
                  fontSize: 16,
                  color: controller.isRecording.value
                      ? Colors.red
                      : Colors.orange.shade600,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
              ),
              const Gap(height: 16),
              // Progress bar section (only show when there's a recording)
              Obx(
                () => controller.hasRecording.value
                    ? Column(
                        children: [
                          // Progress bar with time labels
                          Row(
                            children: [
                              // Current time
                              Obx(
                                () => AppText(
                                  text: controller.isPlaying.value
                                      ? controller.formattedCurrentPosition
                                      : '0:00',
                                  color: Colors.black87,
                                  fontSize: AppSize.width(value: 12),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Obx(
                                    () => SliderTheme(
                                      data: SliderTheme.of(Get.context!)
                                          .copyWith(
                                            trackHeight: 4.0,
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                                  enabledThumbRadius: 6.0,
                                                ),
                                            overlayShape:
                                                const RoundSliderOverlayShape(
                                                  overlayRadius: 12.0,
                                                ),
                                            activeTrackColor: AppColors.blue300,
                                            inactiveTrackColor: Colors.grey
                                                .withValues(alpha: 0.3),
                                            thumbColor: AppColors.blue300,
                                            overlayColor: AppColors.blue300
                                                .withValues(alpha: 0.2),
                                          ),
                                      child: Slider(
                                        value: controller.playbackProgress.value
                                            .clamp(0.0, 1.0),
                                        onChanged: (value) {
                                          controller.seekTo(value);
                                        },
                                        min: 0.0,
                                        max: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Total time
                              Obx(
                                () => AppText(
                                  text:
                                      controller
                                          .formattedTotalDuration
                                          .isNotEmpty
                                      ? controller.formattedTotalDuration
                                      : controller.formattedDuration,
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Gap(height: 16),
                        ],
                      )
                    : Container(),
              ),
              // Playback controls and duration
              Obx(
                () => controller.hasRecording.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Play button
                          GestureDetector(
                            onTap: () => controller.togglePlayback(),
                            child: Container(
                              width: 50,
                              height: 35,
                              decoration: BoxDecoration(
                                color: controller.isPlaying.value
                                    ? Colors.red
                                    : Colors.orange.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                controller.isPlaying.value
                                    ? Icons.stop
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const Gap(width: 16),
                          // Recording duration
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: controller.isRecording.value
                                  ? Colors.red
                                  : Colors.green.shade500,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.formattedDuration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ),
              const Gap(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.resetRecordingState();
                      Get.back();
                    },
                    child: AppText(
                      text: AppString.cancel.tr,
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.hasRecording.value
                          ? () async {
                              Get.back();
                              await controller.saveAudioNote();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue500,
                        disabledBackgroundColor: AppColors.blue100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: AppText(
                        text: AppString.saveNote.tr,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showNoteDetails(
    Map<String, dynamic> note,
    int index,
    NoteVeiwController controller,
  ) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note, size: 20, color: AppColors.blue500),
                          const SizedBox(width: 8),
                          AppText(
                            text:
                                note['createdBy'] ?? AppString.unknownUser.tr,
                            fontSize: 16,
                            color: AppColors.blue500,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.formatTime(
                          note['timestamp'] ?? DateTime.now(),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      // Content types indicator
                      if (_getContentTypesCount(note) > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blue50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getContentSummary(note),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.blue700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Content Section
                    if (_hasTextContent(note)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.text_fields,
                                  size: 18,
                                  color: AppColors.blue500,
                                ),
                                const SizedBox(width: 8),
                                AppText(
                                  text: AppString.textContent.tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blue500,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SelectableText(
                              _getTextContent(note),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Images Section
                    if (_hasImages(note)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 18,
                                  color: Colors.green[600],
                                ),
                                const SizedBox(width: 8),
                                AppText(
                                  text:
                                      '${AppString.images.tr} (${_getImagesCount(note)})',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[600],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1.0,
                                  ),
                              itemCount: _getImagesCount(note),
                              itemBuilder: (context, imageIndex) {
                                final imagePath =
                                    (note['images'] as List)[imageIndex]
                                        .toString();
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to full screen image preview
                                    final List<String> imageList =
                                        (note['images'] as List)
                                            .map((img) => img.toString())
                                            .toList();
                                    Get.to(
                                      () => ImagePreviewScreen(
                                        images: imageList,
                                        initialIndex: imageIndex,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildImageWidget(imagePath),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const Gap(height: 16),
                    ],
                    // Audio Section
                    if (_hasAudio(note)) ...[
                      EnhancedAudioPlayer(
                        audioPath: _getAudioPath(note),
                        audioTitle: _getAudioTitle(note),
                        duration: note['duration'] ?? '0:00',
                      ),
                    ],
                    // If no content found, show message
                    if (!_hasTextContent(note) &&
                        !_hasImages(note) &&
                        !_hasAudio(note)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            AppText(
                              text:
                                  AppString.noContentAvailableForThisNote.tr,
                              fontSize: AppSize.width(value: 16),
                              color: Colors.grey[600],
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showSelectedImagesUI(NotesScreenController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.71,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Obx(
                    () => AppText(
                      text:
                          '${AppString.selectedImagesCount.tr} (${controller.selectedImages.length})',
                      fontSize: AppSize.width(value: 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      AppButton(
                        onTap: () {
                          controller.selectedImages.clear();
                          Get.back();
                        },
                        height: AppSize.height(value: 40),
                        width: AppSize.width(value: 80),
                        fontSize: AppSize.width(value: 12),
                        title: AppString.cancel.tr,
                        backgroundColor: AppColors.blue500,
                        titleColor: AppColors.white100,
                      ),
                      AppButton(
                        onTap: () {
                          Get.back();
                          controller.sendSelectedImages();
                        },
                        height: AppSize.height(value: 40),
                        width: AppSize.width(value: 80),
                        fontSize: AppSize.width(value: 12),
                        title: AppString.saveNote.tr,
                        backgroundColor: AppColors.blue500,
                        titleColor: AppColors.white100,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(
                () => GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: controller.selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(controller.selectedImages[index].path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
