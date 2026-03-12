import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_config.dart';
import 'core/router/app_router.dart';
import 'services/legal_compliance_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables before anything else
  await dotenv.load(fileName: ".env");
  
  await Hive.initFlutter();
  await Hive.openBox('cases');
  
  // Initialize configuration
  await AppConfig.initialize();
  
  // Initialize legal compliance service
  await LegalComplianceService.initialize();
  
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  runApp(ProviderScope(child: JusLegalApp(showOnboarding: !seenOnboarding)));
}

class JusLegalApp extends StatelessWidget {
  final bool showOnboarding;
  const JusLegalApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(showOnboarding: showOnboarding);
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
