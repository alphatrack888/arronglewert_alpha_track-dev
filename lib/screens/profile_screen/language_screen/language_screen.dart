import 'package:alpha_track/screens/profile_screen/language_screen/controller/language_screen_controller.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_text_styles/app_text_styles.dart';
import '../../../widgets/ds/ds_auth_header.dart';
import '../../../widgets/ds/ds_card.dart';

/// Preferences (2026 redesign — matches Figma 73:3810): language picker with a
/// check on the active locale, theme, and notification toggles.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final controller = Get.find<LanguageScreenController>();

  // Supported locales shown in their native form, with a check on the active one.
  static const _languages = [
    {'code': 'english', 'name': 'English'},
    {'code': 'german', 'name': 'Deutsch'},
    {'code': 'arabic', 'name': 'العربية'},
    {'code': 'romanian', 'name': 'Română'},
  ];

  late String _lang;
  bool _emailNotif = true;
  bool _appNotif = true;
  bool _breakNotif = true;
  bool _leaveNotif = true;

  @override
  void initState() {
    super.initState();
    _lang = StorageServices.instance.getLanguage() ?? 'english';
  }

  void _select(String code) {
    setState(() => _lang = code);
    controller.changeLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsAuthHeader(title: 'preferences'.tr),
              const SizedBox(height: 24),

              // LANGUAGE
              _sectionLabel('Language'),
              const SizedBox(height: 10),
              DsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < _languages.length; i++) ...[
                      if (i != 0) _divider(),
                      _languageRow(
                          _languages[i]['code']!, _languages[i]['name']!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // THEME
              _sectionLabel('Theme'),
              const SizedBox(height: 10),
              DsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _staticRow(
                      label: 'Light',
                      trailing: const Icon(LucideIcons.check,
                          color: AppColors.primary, size: 20),
                    ),
                    _divider(),
                    _staticRow(
                      label: 'Dark',
                      trailing:
                          Text('comingSoon'.tr, style: AppTextStyles.subtitle),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // NOTIFICATIONS
              _sectionLabel('Notifications'),
              const SizedBox(height: 10),
              DsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _switchRow('emailNotifications'.tr, _emailNotif,
                        (v) => setState(() => _emailNotif = v)),
                    _divider(),
                    _switchRow('appNotifications'.tr, _appNotif,
                        (v) => setState(() => _appNotif = v)),
                    _divider(),
                    _switchRow('breakReminders'.tr, _breakNotif,
                        (v) => setState(() => _breakNotif = v)),
                    _divider(),
                    _switchRow('leaveReminders'.tr, _leaveNotif,
                        (v) => setState(() => _leaveNotif = v)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) =>
      Text(text.toUpperCase(), style: AppTextStyles.eyebrow);

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 1, color: AppColors.stroke),
    );
  }

  Widget _languageRow(String code, String name) {
    final selected = _lang == code;
    return GestureDetector(
      onTap: () => _select(code),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(name, style: AppTextStyles.bodySemibold)),
            if (selected)
              const Icon(LucideIcons.check, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _staticRow({required String label, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySemibold)),
          trailing,
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySemibold)),
          GestureDetector(
            onTap: () => onChanged(!value),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 44,
              height: 26,
              padding: const EdgeInsets.all(3),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : AppColors.stroke,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
