import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProjectDetailsShimmer extends StatelessWidget {
  const ProjectDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(height: AppSize.height(value: 10)),

          // Image shimmer
          Shimmer.fromColors(
            baseColor: AppColors.black100,
            highlightColor: AppColors.white200,
            child: Container(
              width: AppSize.width(value: 335),
              height: AppSize.height(value: 185),
              decoration: BoxDecoration(
                color: AppColors.black100,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          Gap(height: AppSize.height(value: 12)),

          // Title shimmer
          Shimmer.fromColors(
            baseColor: AppColors.black100,
            highlightColor: AppColors.white200,
            child: Container(
              width: AppSize.width(value: 250),
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.black100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          Gap(height: AppSize.height(value: 15)),

          // Description label shimmer
          Shimmer.fromColors(
            baseColor: AppColors.black100,
            highlightColor: AppColors.white200,
            child: Container(
              width: AppSize.width(value: 120),
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.black100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          Gap(height: AppSize.height(value: 8)),

          // Description lines shimmer
          Shimmer.fromColors(
            baseColor: AppColors.black100,
            highlightColor: AppColors.white200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.black100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 14,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.black100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: AppSize.width(value: 280),
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.black100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          Gap(height: AppSize.height(value: 20)),

          // Audio label shimmer
          Shimmer.fromColors(
            baseColor: AppColors.black100,
            highlightColor: AppColors.white200,
            child: Container(
              width: AppSize.width(value: 140),
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.black100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          Gap(height: AppSize.height(value: 10)),

          // Audio player shimmer
          Shimmer.fromColors(
            baseColor: AppColors.black100,
            highlightColor: AppColors.white200,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.black100,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          Gap(height: AppSize.height(value: 20)),
        ],
      ),
    );
  }
}
