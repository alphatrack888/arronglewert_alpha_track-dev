import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/storage_services/storage_services.dart';

class LanguageScreenController extends GetxController {
  void changeLanguage(String languageCode) {
    var locale = Locale(languageCode);
    Get.updateLocale(locale);
    StorageServices.instance.setLanguage(languageCode);
  }
}
