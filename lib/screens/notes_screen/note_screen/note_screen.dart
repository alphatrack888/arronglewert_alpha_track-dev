import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/notes_screen/note_screen/controller/notes_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
              color: AppColors.primary,
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(height: AppSize.height(value: 13)),
              Text(
                AppString.myallProject.tr,
                style: AppTextStyles.titleSmall,
              ),
              Gap(height: AppSize.height(value: 12)),
              // Check if data exists
              if (controller.allProjectData.value?.data?.data != null)
                ...controller.allProjectData.value!.data!.data!.map((project) {
                  return DsCard(
                    margin: const EdgeInsets.only(bottom: 12),
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
                            Expanded(
                              child: Text(
                                project.title ?? 'untitledProject'.tr,
                                style: AppTextStyles.bodySemibold,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Gap(height: 8),
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.clockGray,
                              height: AppSize.height(value: 20),
                              width: AppSize.width(value: 20),
                            ),
                            Gap(width: AppSize.width(value: 10)),
                            Text(
                              '${project.projectTime ?? 0} hours',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Spacer(),
                            AppButton(
                              title: AppString.view.tr,
                              backgroundColor: AppColors.primary,
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
                                    'projectIdMissing'.tr,
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
                          Gap(height: 8),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.building2,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                              Gap(width: AppSize.width(value: 10)),
                              Expanded(
                                child: Text(
                                  project.company!.name!,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                    child: Text(
                      AppString.noProjectsAvailable.tr,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 15),
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
