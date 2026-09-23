import 'package:alpha_track/screens/profile_screen/personal_information/controller/personal_information_controller.dart';
import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  final PersonalInformationController _controller =
      Get.find<PersonalInformationController>();
  final ImagePickerService _imagePickerService = ImagePickerService();
  bool _isImageLoading = false;

  /// Method to pick and update image
  Future<void> _pickAndUpdateImage() async {
    try {
      setState(() {
        _isImageLoading = true;
      });
      appLog('📄 Starting image selection...');
      final pickedImage = await _imagePickerService.pickImage(context);
      if (pickedImage != null) {
        appLog('✅ Image selected successfully: ${pickedImage.path}');
        _controller.setProfileImage(pickedImage);
        AppSnackBar.success(AppString.imageSelectedSuccessfully.tr);
      } else {
        appLog('❌ No image was selected');
      }
    } catch (e) {
      appLog('❌ Error selecting image: $e');
      if (mounted) {
        AppSnackBar.error('${AppString.errorSelectingImage.tr}: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.personalInformation,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(height: AppSize.height(value: 25)),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Profile Image
                    Obx(
                      () => CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _controller.profileImage.value != null
                            ? FileImage(_controller.profileImage.value!)
                            : null,
                        child: _controller.profileImage.value == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    // Loading Overlay
                    if (_isImageLoading)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Center(
                          child: LoadingAnimationWidget.beat(
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    // Edit Button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isImageLoading ? null : _pickAndUpdateImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isImageLoading
                                ? Colors.grey
                                : AppColors.blue500,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            _isImageLoading
                                ? Icons.hourglass_empty
                                : Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //! Name Field
              Gap(height: 15),
              AppText(
                text: AppString.fullName,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black500,
              ),
              Gap(height: AppSize.height(value: 05)),
              CustomTextField(
                hintText: AppString.enterYourFullName,
                height: AppSize.height(value: 48),
                controller: _controller.fullNameController,
                backgroundColor: AppColors.blue50,
                borderRadius: 6,
                borderColor: Colors.transparent,
                keyboardType: TextInputType.name,
              ),
              Gap(height: AppSize.height(value: 12)),
              //! Contact Number
              AppText(
                text: AppString.contactNumber,
                fontSize: AppSize.width(value: 14),
                fontWeight: FontWeight.w600,
                color: AppColors.black500,
              ),
              Gap(height: 05),
              CustomTextField(
                hintText: AppString.enterYourContactNumber,
                height: AppSize.height(value: 48),
                controller: _controller.contactNumberController,
                backgroundColor: AppColors.blue50,
                borderRadius: 6,
                borderColor: Colors.transparent,
                keyboardType: TextInputType.number,
              ),
              Gap(height: AppSize.height(value: 20)),
              AppButton(
                title: _controller.isLoading.value
                    ? AppString.updating.tr
                    : AppString.editNow.tr,
                height: AppSize.height(value: 48),
                width: double.infinity,
                backgroundColor: _controller.isLoading.value
                    ? Colors.grey
                    : AppColors.blue500,
                borderradius: 6,
                onTap: _controller.isLoading.value
                    ? null
                    : () async {
                        await _controller.updateProfile();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
