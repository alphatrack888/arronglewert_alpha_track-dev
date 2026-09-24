import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/core/bindings/initial_bindings.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_device_utils/app_device_utils.dart';
import 'package:alpha_track/widgets/getx_observer/getx_custome_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'core/app_translation/app_translation.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation first
  DeviceUtils.lockDevicePortrait();

  // Initialize platform channels with error handling
  await initializePlatformChannels();

  // Initialize storage with enhanced error handling
  await initializeStorage();

  // Initialize bindings
  InitialBinding().dependencies();

  await initializePushNotifications();

  runApp(MyApp());
}

Future<void> initializePushNotifications() async {
  try {
    // No explicit FirebaseOptions here (no `firebase_options.dart` /
    // DefaultFirebaseOptions) — this app is mobile-only, so Firebase reads
    // its config from the native google-services.json (Android) /
    // GoogleService-Info.plist (iOS) files instead. Those aren't committed
    // (real project credentials, one per environment) — see
    // android/app/README_FIREBASE_SETUP.md / ios/Runner/README_FIREBASE_SETUP.md.
    await Firebase.initializeApp();
    await PushNotificationService.instance.initialize();
    appLog('Push notifications initialized');
  } catch (e) {
    // Deliberately non-fatal: a missing/misconfigured Firebase project must
    // not crash the app or block startup — it should just mean push doesn't
    // work this session, same as the existing "continue without path
    // provider" pattern above.
    appLog('Push notification initialization failed (continuing without push): $e');
  }
}

Future<void> initializePlatformChannels() async {
  try {
    // Test path provider availability
    final directory = await getApplicationSupportDirectory();
    appLog('Path provider initialized successfully: ${directory.path}');
  } catch (e) {
    appLog('Path provider initialization failed: $e');
    // Continue without path provider - app will use fallback storage
  }

  // Add a longer delay in release mode to ensure platform channels are ready
  if (kReleaseMode) {
    await Future.delayed(const Duration(milliseconds: 1000));
  } else {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

Future<void> initializeStorage() async {
  // ignore: unused_local_variable
  bool storageInitialized = false;

  try {
    // Skip GetStorage entirely and use SharedPreferences directly
    // This avoids the path_provider dependency issue completely
    StorageServices storageServices = StorageServices.instance;
    await storageServices.initializeFallbackStorage();

    storageInitialized = true;
    appLog(
      'Storage initialized successfully with SharedPreferences (bypassing GetStorage path_provider issue)',
    );
  } catch (e) {
    appLog('Storage initialization failed: $e');
    appLog('App will continue with limited functionality.');
    // Even if storage fails completely, allow the app to continue
    storageInitialized = true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Covers the edge case where the user denied push permission, then
    // granted it later from OS Settings without going through login again
    // — re-checked on every resume, not just at app start.
    if (state == AppLifecycleState.resumed) {
      PushNotificationService.instance.refreshRegistrationIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String savedLanguage =
        StorageServices.instance.getLanguage() ?? 'english';
    return GetMaterialApp(
      translations: AppTranslation(),
      locale: Locale(savedLanguage),
      fallbackLocale: const Locale('english'),
      navigatorObservers: [NavigationObserver()],
      useInheritedMediaQuery: true,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
      initialRoute: AppRoute.splashScreen,
      navigatorKey: Get.key,
      getPages: AppRoute.appRoutes,
      // Add error handling for the entire app
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
      },
    );
  }
}
