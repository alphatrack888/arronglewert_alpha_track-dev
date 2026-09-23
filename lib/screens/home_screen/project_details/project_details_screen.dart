import 'package:alpha_track/screens/home_screen/project_details/controller/project_details_screen_controller.dart';
import 'package:alpha_track/screens/home_screen/project_details/widgets/project_details_shimmer.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_audio_player/app_audio_player.dart';
import 'package:alpha_track/widgets/app_images/app_images.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late final ProjectDetailsScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProjectDetailsScreenController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.viewingProject.tr,
        backgroundColor: AppColors.white200,
        showAction: false,
        showLeading: true,
      ),
      backgroundColor: AppColors.white200,
      body: Obx(() {
        // Show shimmer while loading
        if (controller.apiLoadingState.value ==
            LoadingStateProjectDetails.loading) {
          return const ProjectDetailsShimmer();
        }

        // Show content when loaded
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(height: AppSize.height(value: 10)),
                // Image with debugging info
                Obx(() {
                  final images =
                      controller.singleProjectData.value?.data?.images;
                  final imageUrl = (images != null && images.isNotEmpty)
                      ? images[0]
                      : '';

                  // Debug: Print the image URL
                  appLog('Image URL from API: $imageUrl');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isEmpty)
                        Container(
                          width: AppSize.width(value: 335),
                          height: AppSize.height(value: 185),
                          decoration: BoxDecoration(
                            color: AppColors.black100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.black200,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: AppColors.black300,
                                ),
                                SizedBox(height: 8),
                                AppText(
                                  text: AppString
                                      .noImageAvailableForThisProject
                                      .tr,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black300,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        AppImage(
                          shape: ImageShape.rectangle,
                          width: AppSize.width(value: 335),
                          height: AppSize.height(value: 185),
                          url: imageUrl,
                          fit: BoxFit.cover,
                        ),
                    ],
                  );
                }),

                Gap(height: AppSize.height(value: 12)),
                Obx(() {
                  final title = controller.singleProjectData.value?.data?.title;

                  if (title == null || title.isEmpty) {
                    return AppText(
                      text: AppString.noTitleAvailableForThisProject.tr,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black300,
                      height: 1.5,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return AppText(
                    text: title,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black500,
                    height: 1.5,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
                Gap(height: AppSize.height(value: 5)),

                // Description Text
                Gap(height: AppSize.height(value: 10)),
                AppText(
                  text: AppString.description.tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black500,
                  height: 1.5,
                ),
                Gap(height: AppSize.height(value: 3)),
                Obx(() {
                  final description =
                      controller.singleProjectData.value?.data?.description;

                  if (description == null || description.isEmpty) {
                    return AppText(
                      text: AppString.noDescriptionAvailableForThisProject.tr,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black300,
                      height: 1.5,
                      maxLines: 10,
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                    );
                  }

                  return AppText(
                    text: description,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black300,
                    height: 1.5,
                    maxLines: 10,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                  );
                }),

                // Task Features
                // Gap(height: AppSize.height(value: 10)),
                // const AppText(
                //   text: AppString.keyFetures,
                //   fontSize: 16,
                //   fontWeight: FontWeight.w600,
                //   color: AppColors.black500,
                //   height: 1.5,
                // ),
                // Gap(height: AppSize.height(value: 3)),
                // const AppText(
                //   text: AppString.descriptionDetails,
                //   fontSize: 14,
                //   fontWeight: FontWeight.w500,
                //   color: AppColors.black300,
                //   height: 1.5,
                //   maxLines: 10,
                //   textAlign: TextAlign.justify,
                //   overflow: TextOverflow.ellipsis,
                // ),
                // Audio Playing
                Gap(height: AppSize.height(value: 15)),
                AppText(
                  text: AppString.relatedAudio.tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black500,
                  height: 1.5,
                ),
                Gap(height: AppSize.height(value: 10)),
                Obx(() {
                  final audioUrl =
                      controller.singleProjectData.value?.data?.audio ?? '';
                  if (audioUrl.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.blue100, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.audiotrack_outlined,
                            size: 24,
                            color: AppColors.black300,
                          ),
                          SizedBox(width: 12),
                          AppText(
                            text: AppString.noAudioAvailableForThisProject.tr,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black300,
                          ),
                        ],
                      ),
                    );
                  }
                  return AppAudioPlayer(audioUrl: audioUrl);
                }),
                Gap(height: AppSize.height(value: 20)),
              ],
            ),
          ),
        );
      }),
    );
  }
}
