import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:alpha_track/screens/notes_screen/note_screen/controller/notes_screen_controller.dart';
import 'package:alpha_track/screens/notes_screen/notes_view/controller/note_veiw_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:alpha_track/widgets/ds/ds_bottom_sheet.dart';
import 'package:alpha_track/widgets/ds/ds_dialog.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:alpha_track/widgets/app_audio_player/enhanced_audio_player.dart';
import 'package:alpha_track/widgets/image_preview_widget/image_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.filePlus, size: 64, color: AppColors.textFaint),
          const Gap(height: 16),
          Text(
            AppString.noNotesYet.tr,
            style: AppTextStyles.title.copyWith(fontSize: 18),
          ),
          const Gap(height: 8),
          Text(
            AppString.tapPlusToCreateFirstNote.tr,
            style: AppTextStyles.subtitle,
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
          return Icon(LucideIcons.imageOff, color: Colors.grey);
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
          return Icon(LucideIcons.imageOff, color: Colors.grey);
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
    return DsCard(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.zero,
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
                        color: AppColors.primary,
                      ),
                      const Gap(width: 6),
                      Text(
                        note['createdBy'] ?? AppString.unknownUser.tr,
                        style: AppTextStyles.bodySemibold,
                      ),
                    ],
                  ),
                  Text(
                    controller.formatTime(note['timestamp'] ?? DateTime.now()),
                    style: AppTextStyles.caption,
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
                            LucideIcons.type,
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
                            LucideIcons.image,
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
                  Text(
                    AppString.tapToViewDetails.tr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.arrowRight,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
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
      return LucideIcons.layers; // Mixed content
    } else if (_hasImages(note)) {
      return LucideIcons.image;
    } else if (_hasAudio(note)) {
      return LucideIcons.mic;
    } else {
      return LucideIcons.stickyNote;
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
    DsBottomSheet.show(
      DsBottomSheet(
        title: AppString.createNewNote.tr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DsSheetAction(
              icon: LucideIcons.layers,
              label: AppString.mixedNote.tr,
              onTap: () {
                Get.back();
                _showMixedNoteDialog(controller);
              },
            ),
            DsSheetAction(
              icon: LucideIcons.type,
              label: AppString.textNote.tr,
              onTap: () {
                Get.back();
                _showTextNoteDialog(controller);
              },
            ),
            DsSheetAction(
              icon: LucideIcons.image,
              label: AppString.imageNote.tr,
              onTap: () {
                Get.back();
                notesScreenController.sendPhoto();
              },
            ),
            DsSheetAction(
              icon: LucideIcons.mic,
              label: AppString.audioNote.tr,
              onTap: () {
                Get.back();
                _showAdvancedAudioRecordingDialog(controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMixedNoteDialog(NoteVeiwController controller) {
    controller.textController.clear();
    controller.selectedImages.clear();
    controller.resetRecordingState();

    Get.dialog(
      DsDialog(
        title: AppString.createMixedNote.tr,
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Section
                  Text(
                    AppString.textContentOptional.tr,
                    style: AppTextStyles.eyebrow,
                  ),
                  const Gap(height: 8),
                  CustomTextField(
                    hintText: AppString.writeYourNoteHere.tr,
                    maxLines: 3,
                    controller: controller.textController,
                    backgroundColor: AppColors.fill,
                  ),
                  const Gap(height: 16),

                  // Images Section
                  Text(
                    AppString.imagesOptional.tr,
                    style: AppTextStyles.eyebrow,
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
                              color: AppColors.fill,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.stroke),
                            ),
                            child: Center(
                              child: Text(
                                AppString.noImagesSelected.tr,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ),
                  ),
                  const Gap(height: 8),
                  SecondaryButton(
                    label: AppString.addImages.tr,
                    isTranslate: false,
                    icon: LucideIcons.imagePlus,
                    height: 44,
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images = await picker.pickMultiImage();
                      if (images.isNotEmpty) {
                        controller.selectedImages.addAll(images);
                      }
                    },
                  ),
                  const Gap(height: 16),

                  // Audio Section
                  Text(
                    AppString.audioRecordingOptional.tr,
                    style: AppTextStyles.eyebrow,
                  ),
                  const Gap(height: 8),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.fill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.stroke),
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
                                    ? AppColors.danger
                                    : AppColors.primary,
                              ),
                              child: Icon(
                                controller.isRecording.value
                                    ? LucideIcons.square
                                    : LucideIcons.mic,
                                color: AppColors.white50,
                                size: 20,
                              ),
                            ),
                          ),
                          const Gap(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.isRecording.value
                                      ? AppString.recording.tr
                                      : controller.hasRecording.value
                                          ? AppString.recordingReady.tr
                                          : AppString.tapToRecord.tr,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                                if (controller.hasRecording.value)
                                  Text(
                                    controller.formattedDuration,
                                    style: AppTextStyles.caption,
                                  ),
                              ],
                            ),
                          ),
                          if (controller.hasRecording.value)
                            GestureDetector(
                              onTap: () => controller.togglePlayback(),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: controller.isPlaying.value
                                      ? AppColors.danger
                                      : AppColors.success,
                                ),
                                child: Icon(
                                  controller.isPlaying.value
                                      ? LucideIcons.square
                                      : LucideIcons.play,
                                  color: AppColors.white50,
                                  size: 18,
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
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: AppString.cancel.tr,
                          isTranslate: false,
                          height: 48,
                          onTap: () {
                            Get.back();
                          },
                        ),
                      ),
                      const Gap(width: 12),
                      Expanded(
                        child: Obx(
                        () => PrimaryButton(
                          isLoading: controller.isLoading.value,
                          height: 48,
                          isTranslate: false,
                          label: controller.isLoading.value
                              ? AppString.creating.tr
                              : AppString.createNote.tr,
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
                        ),
                        ),
                      ),
                    ],
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTextNoteDialog(NoteVeiwController controller) {
    controller.textController.clear();
    Get.dialog(
      DsDialog(
        title: AppString.createTextNote.tr,
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                hintText: AppString.writeYourNoteHere.tr,
                maxLines: 5,
                controller: controller.textController,
                backgroundColor: AppColors.fill,
              ),
            ],
          ),
        cancelLabel: AppString.cancel.tr,
        confirmLabel: AppString.saveNote.tr,
        onConfirm: () async {
          await controller.sendMessage();
        },
      ),
    );
  }

  void _showAdvancedAudioRecordingDialog(NoteVeiwController controller) {
    // Reset recording state
    controller.resetRecordingState();
    DsBottomSheet.show(
      DsBottomSheet(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row: Cancel / Record Audio / Done
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.resetRecordingState();
                      Get.back();
                    },
                    child: Text(
                      AppString.cancel.tr,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    'recordAudio'.tr,
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  Obx(
                    () => GestureDetector(
                      onTap: controller.hasRecording.value
                          ? () async {
                              Get.back();
                              await controller.saveAudioNote();
                            }
                          : null,
                      child: Text(
                        'Done',
                        style: AppTextStyles.bodySemibold.copyWith(
                          fontSize: 16,
                          color: controller.hasRecording.value
                              ? AppColors.primary
                              : AppColors.textFaint,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(height: 36),

              // Waveform / prompt area
              Obx(() {
                final bool active = controller.isRecording.value ||
                    controller.hasRecording.value;
                if (!active) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          'clickStartToRecord'.tr,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 15,
                          ),
                        ),
                        const Gap(height: 18),
                        SizedBox(
                          height: 24,
                          child: _RecorderWaveform(
                            active: false,
                            tick: controller.recordingDuration.value,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: _RecorderWaveform(
                        active: controller.isRecording.value,
                        tick: controller.recordingDuration.value,
                      ),
                    ),
                    const Gap(height: 20),
                    Text(
                      _formatRecorderClock(controller.recordingDuration.value),
                      style: AppTextStyles.title.copyWith(fontSize: 22),
                    ),
                  ],
                );
              }),
              const Gap(height: 36),

              // Action button: Start (idle) / Pause (recording) / Resume (stopped)
              Obx(() {
                if (controller.isLoading.value) {
                  return SizedBox(
                    height: 52,
                    child: Center(
                      child: LoadingAnimationWidget.beat(
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }
                if (controller.isRecording.value) {
                  // Recording in progress -> Pause/Stop (red)
                  return SecondaryButton(
                    label: 'Pause',
                    isTranslate: false,
                    color: AppColors.danger,
                    onTap: () => controller.toggleRecording(),
                  );
                }
                if (controller.hasRecording.value) {
                  // Stopped with a recording -> Resume (red, restarts recording)
                  return SecondaryButton(
                    label: 'Resume',
                    isTranslate: false,
                    color: AppColors.danger,
                    onTap: () => controller.toggleRecording(),
                  );
                }
                // Idle -> Start
                return SecondaryButton(
                  label: 'Start',
                  isTranslate: false,
                  icon: LucideIcons.mic,
                  onTap: () => controller.toggleRecording(),
                );
              }),
            ],
          ),
      ),
    );
  }

  String _formatRecorderClock(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _showNoteDetails(
    Map<String, dynamic> note,
    int index,
    NoteVeiwController controller,
  ) {
    DsBottomSheet.show(
      DsBottomSheet(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: Get.height * 0.8,
          child: Column(
          children: [
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
                          Icon(LucideIcons.stickyNote, size: 20, color: AppColors.blue500),
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
                    icon: const Icon(LucideIcons.x),
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
                                  LucideIcons.type,
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
                                  LucideIcons.image,
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
                              LucideIcons.info,
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
      ),
    );
  }

  void _showSelectedImagesUI(NotesScreenController controller) {
    DsBottomSheet.show(
      DsBottomSheet(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: Get.height * 0.71,
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
                              LucideIcons.imageOff,
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
      ),
    );
  }
}

/// Decorative waveform for the Record Audio sheet. When [active] the centre
/// bars are emphasised in the brand colour; otherwise it renders a flat row of
/// muted dots ("Click Start to record" prompt). Purely visual — does not drive
/// any recording logic.
class _RecorderWaveform extends StatelessWidget {
  const _RecorderWaveform({required this.active, required this.tick});

  final bool active;
  final int tick;

  @override
  Widget build(BuildContext context) {
    const int count = 41;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(count, (i) {
            final distFromCenter = (i - count ~/ 2).abs() / (count / 2);
            // Bell-shaped envelope, taller in the middle.
            double factor = (1 - distFromCenter);
            if (active) {
              // Add a little per-bar variation that shifts with the timer tick.
              final wobble = (((i * 7 + tick * 3) % 10) / 10) * 0.4;
              factor = (factor + wobble).clamp(0.12, 1.0);
            } else {
              factor = 0.12;
            }
            final isLit = active && distFromCenter < 0.55;
            return Container(
              width: 3,
              height: (maxH * factor).clamp(4.0, maxH),
              decoration: BoxDecoration(
                color: isLit ? AppColors.primary : AppColors.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
