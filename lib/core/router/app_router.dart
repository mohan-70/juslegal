import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/home_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/problem_analyzer_screen.dart';
import '../../screens/result_screen.dart';
import '../../screens/complaint_generator_screen.dart';
import '../../screens/my_cases_screen.dart';
import '../../screens/authorities_screen.dart';
import '../../screens/settings_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouteNames {
  static const String onboarding = 'onboarding';
  static const String home = 'home';
  static const String analyzer = 'analyzer';
  static const String result = 'result';
  static const String complaint = 'complaint';
  static const String cases = 'cases';
  static const String authorities = 'authorities';
  static const String settings = 'settings';
}

GoRouter buildRouter({bool showOnboarding = true}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: showOnboarding ? '/onboarding' : '/home',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: AppRouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRouteNames.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'analyzer',
            name: AppRouteNames.analyzer,
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return ProblemAnalyzerScreen(initialCategory: category);
            },
          ),
          GoRoute(
            path: 'result',
            name: AppRouteNames.result,
            builder: (context, state) => const ResultScreen(),
          ),
          GoRoute(
            path: 'complaint',
            name: AppRouteNames.complaint,
            builder: (context, state) => const ComplaintGeneratorScreen(),
          ),
          GoRoute(
            path: 'cases',
            name: AppRouteNames.cases,
            builder: (context, state) => const MyCasesScreen(),
          ),
          GoRoute(
            path: 'authorities',
            name: AppRouteNames.authorities,
            builder: (context, state) => const AuthoritiesScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: AppRouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
