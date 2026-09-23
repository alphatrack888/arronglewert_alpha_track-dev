import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/notes_screen/note_screen/controller/notes_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final NotesScreenController controller = Get.find<NotesScreenController>();

    // Load data when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllProjectData();
    });

    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.notes.tr,
        showAction: false,
        showLeading: false,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.beat(
              size: 50,
              color: AppColors.blue500,
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(height: AppSize.height(value: 13)),
              AppText(
                text: AppString.myallProject.tr,
                fontSize: AppSize.width(value: 16),
                fontWeight: FontWeight.w600,
                color: AppColors.black500,
              ),
              Gap(height: AppSize.height(value: 10)),
              // Check if data exists
              if (controller.allProjectData.value?.data?.data != null)
                ...controller.allProjectData.value!.data!.data!.map((project) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.blue50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors
                            .transparent, // You can add selection logic here if needed
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.projectgray,
                              height: AppSize.height(value: 20),
                              width: AppSize.width(value: 20),
                            ),
                            Gap(width: AppSize.width(value: 10)),
                            AppText(
                              text: project.title ?? 'Untitled Project',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black400,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Gap(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.clockGray,
                              height: AppSize.height(value: 20),
                              width: AppSize.width(value: 20),
                            ),
                            Gap(width: AppSize.width(value: 10)),
                            AppText(
                              text: '${project.projectTime ?? 0} hours',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black400,
                            ),
                            Spacer(),
                            AppButton(
                              title: AppString.view.tr,
                              backgroundColor: AppColors.blue500,
                              titleColor: AppColors.white100,
                              width: AppSize.width(
                                value: 70,
                              ), // Adjusted to match original
                              height: AppSize.height(
                                value: 35,
                              ), // Adjusted to match original
                              fontSize: AppSize.width(value: 13),
                              onTap: () {
                                if (project.id != null &&
                                    project.id!.isNotEmpty) {
                                  appLog(
                                    '🚀 Navigating to noteView with project ID: ${project.id}',
                                  );
                                  Get.toNamed(
                                    AppRoute.noteView,
                                    arguments: project.id,
                                  );
                                } else {
                                  appLog(
                                    '❌ Project ID is null or empty: ${project.id}',
                                  );
                                  Get.snackbar(
                                    'Error',
                                    'Project ID is missing. Cannot view notes for this project.',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        // Show company info if available
                        if (project.company?.name != null) ...[
                          Gap(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                size: 20,
                                color: AppColors.black400,
                              ),
                              Gap(width: AppSize.width(value: 10)),
                              AppText(
                                text: project.company!.name!,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black400,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList()
              else
                // Show message when no projects available
                Container(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: AppText(
                      text: AppString.noProjectsAvailable.tr,
                      fontSize: 16,
                      color: AppColors.black400,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
