import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_config.dart';
import 'core/constants/firebase_options.dart';
import 'core/router/app_router.dart';
import 'services/legal_compliance_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    // For web, continue without Firebase if it fails
    if (!kIsWeb) {
      rethrow;
    }
  }
  
  // Initialize Firebase Crashlytics only if Firebase is available
  try {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    print('⚠️ Firebase Crashlytics initialization failed: $e');
  }
  
  await Hive.initFlutter();
  await Hive.openBox('cases');
  
  // Initialize configuration
  await AppConfig.initialize();
  
  // Initialize legal compliance service
  await LegalComplianceService.initialize();
  
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  print('🚀 Starting JusLegal App - showOnboarding: $seenOnboarding');
  runApp(ProviderScope(child: JusLegalApp(showOnboarding: !seenOnboarding)));
}

class JusLegalApp extends StatelessWidget {
  final bool showOnboarding;
  const JusLegalApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(showOnboarding: showOnboarding);
    print('🏗️ Building JusLegalApp with showOnboarding: $showOnboarding');
    return MaterialApp.router(
      title: 'JusLegal',
      theme: buildAppTheme(),
      darkTheme: buildAppDarkTheme(),
      themeMode: ThemeMode.system, // Uses system theme, or set to ThemeMode.light for light only
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
