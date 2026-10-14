import 'package:alpha_track/screens/profile_screen/personal_information/controller/personal_information_controller.dart';
import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: DsAuthHeader(title: 'editPersonalInformation'.tr),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Profile Image
                            Obx(
                              () => CircleAvatar(
                                radius: 56,
                                backgroundColor: AppColors.fill,
                                backgroundImage:
                                    _controller.profileImage.value != null
                                    ? FileImage(_controller.profileImage.value!)
                                    : null,
                                child: _controller.profileImage.value == null
                                    ? const Icon(
                                        LucideIcons.user,
                                        size: 56,
                                        color: AppColors.textFaint,
                                      )
                                    : null,
                              ),
                            ),
                            // Loading Overlay
                            if (_isImageLoading)
                              Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(56),
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
                              bottom: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: _isImageLoading
                                    ? null
                                    : _pickAndUpdateImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _isImageLoading
                                        ? AppColors.textFaint
                                        : AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.stroke,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _isImageLoading
                                        ? LucideIcons.hourglass
                                        : LucideIcons.squarePen,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      //! Name Field
                      _fieldLabel(AppString.fullName.tr),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: AppString.enterYourFullName.tr,
                        height: 52,
                        controller: _controller.fullNameController,
                        backgroundColor: AppColors.surface,
                        borderRadius: 12,
                        borderColor: AppColors.stroke,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 18),
                      //! Email
                      _fieldLabel(AppString.email.tr),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: AppString.enterYourEmail.tr,
                        height: 52,
                        controller: _controller.emailController,
                        backgroundColor: AppColors.surface,
                        borderRadius: 12,
                        borderColor: AppColors.stroke,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      //! Phone Number
                      _fieldLabel(AppString.phoneNumber.tr),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: AppString.enterYourContactNumber.tr,
                        height: 52,
                        controller: _controller.contactNumberController,
                        backgroundColor: AppColors.surface,
                        borderRadius: 12,
                        borderColor: AppColors.stroke,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: PrimaryButton(
                  label: _controller.isLoading.value
                      ? AppString.updating.tr
                      : 'saveChanges'.tr,
                  isLoading: _controller.isLoading.value,
                  isTranslate: false,
                  color: _controller.isLoading.value
                      ? AppColors.textFaint
                      : AppColors.primary,
                  onTap: _controller.isLoading.value
                      ? null
                      : () async {
                          final ok = await _controller.updateProfile();
                          if (ok && context.mounted) dsPop(context);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
    );
  }
}
