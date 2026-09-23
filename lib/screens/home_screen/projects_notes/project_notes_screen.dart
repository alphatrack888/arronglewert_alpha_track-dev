import 'dart:io';

import 'package:alpha_track/screens/home_screen/projects_notes/controller/project_notes_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ProjectNotesScreen extends StatelessWidget {
  const ProjectNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the GetX controller
    final ProjectNotesScreenController controller = Get.put(
      ProjectNotesScreenController(),
    );

    Widget buildMessageBubble(Map<String, dynamic> message) {
      if (message['type'] == 'images') {
        return Align(
          alignment: message['isSentByMe']
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: message['isSentByMe'] ? AppColors.blue50 : Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Column(
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
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: message['images'].length > 6
                        ? 6
                        : message['images'].length,
                    itemBuilder: (context, index) {
                      if (index == 5 && message['images'].length > 6) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black54,
                          ),
                          child: Center(
                            child: Text(
                              '+${message['images'].length - 5}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(message['images'][index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8.0),
                Text(
                  controller.formatTime(message['timestamp']),
                  style: const TextStyle(fontSize: 12.0, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      } else {
        return Align(
          alignment: message['isSentByMe']
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: message['isSentByMe'] ? AppColors.blue50 : Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['text'],
                  style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                ),
                const SizedBox(height: 4.0),
                Text(
                  controller.formatTime(message['timestamp']),
                  style: const TextStyle(fontSize: 12.0, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.typeNote.tr,
        showLeading: true,
        showAction: false,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return buildMessageBubble(message);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.textController,
                            decoration: InputDecoration(
                              hintText: AppString.typeHere.tr,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Gap(width: AppSize.width(value: 08)),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blue50,
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(AppIcons.attachPhoto),
                    onPressed: controller.sendPhoto,
                  ),
                ),
                Gap(width: AppSize.width(value: 08)),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blue50,
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(AppIcons.recordingsIcons),
                    onPressed: () {},
                  ),
                ),
                Gap(width: AppSize.width(value: 08)),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blue50,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send),
                    color: AppColors.blue500,
                    onPressed: controller.sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
