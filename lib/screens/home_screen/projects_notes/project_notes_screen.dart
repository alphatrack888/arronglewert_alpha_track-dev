import 'dart:io';

import 'package:alpha_track/screens/home_screen/projects_notes/controller/project_notes_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:get/get.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';

class ProjectNotesScreen extends StatelessWidget {
  const ProjectNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the GetX controller
    final ProjectNotesScreenController controller = Get.put(
      ProjectNotesScreenController(),
    );

    Widget buildNoteCard(Map<String, dynamic> message) {
      final align = message['isSentByMe']
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start;

      Widget body;
      if (message['type'] == 'images') {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message['images'].length == 1)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(message['images'][0]),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: message['images'].length > 4 ? 3 : 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount:
                    message['images'].length > 6 ? 6 : message['images'].length,
                itemBuilder: (context, index) {
                  if (index == 5 && message['images'].length > 6) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.textPrimary.withValues(alpha: 0.55),
                      ),
                      child: Center(
                        child: Text(
                          '+${message['images'].length - 5}',
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.surface),
                        ),
                      ),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(message['images'][index]),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
            Text(
              controller.formatTime(message['timestamp']),
              style: AppTextStyles.caption,
            ),
          ],
        );
      } else {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'],
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              controller.formatTime(message['timestamp']),
              style: AppTextStyles.caption,
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: align,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: DsCard(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(14),
              color: message['isSentByMe']
                  ? AppColors.primarySoft
                  : AppColors.surface,
              child: body,
            ),
          ),
        ],
      );
    }

    Widget circleAction({
      required Widget icon,
      VoidCallback? onPressed,
    }) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const DsBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppString.typeNote.tr,
                      style: AppTextStyles.title,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return buildNoteCard(message);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: TextField(
                        controller: controller.textController,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: AppString.typeHere.tr,
                          hintStyle: AppTextStyles.body
                              .copyWith(color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  circleAction(
                    icon: SvgPicture.asset(AppIcons.attachPhoto),
                    onPressed: controller.sendPhoto,
                  ),
                  const SizedBox(width: 8),
                  circleAction(
                    icon: SvgPicture.asset(AppIcons.recordingsIcons),
                    // TEST MODE: confirm tap with a snackbar.
                    onPressed: () => Get.snackbar(
                        'recording'.tr, 'audioRecordingTest'.tr,
                        snackPosition: SnackPosition.BOTTOM),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.send, size: 20),
                      color: AppColors.surface,
                      onPressed: controller.sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
