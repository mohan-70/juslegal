import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:juslegal/screens/onboarding_screen.dart';
import 'package:juslegal/core/constants/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingScreen Tests', () {
    late GoRouter router;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('Home Screen')),
          ),
        ],
      );
    });

    Widget createOnboardingScreen() {
      return MaterialApp.router(
        theme: buildAppTheme(),
        darkTheme: buildAppDarkTheme(),
        routerConfig: router,
      );
    }

    testWidgets('Renders page 1 correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      expect(find.text('Legal Problem in 3 Taps'), findsOneWidget);
      expect(find.text('Choose Your Issue Category'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Navigates through pages', (WidgetTester tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Page 1 -> Page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Live Demo'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Page 2 -> Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Join 50,000+ Indians'), findsOneWidget);
      expect(find.text('Start Getting Legal Protection'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('Skip button navigates to home', (WidgetTester tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('seen_onboarding'), true);
    });

    testWidgets('Final CTA button navigates to home',
        (WidgetTester tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Move to last page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Getting Legal Protection'));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('seen_onboarding'), true);
    });

    testWidgets('Has accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Check for presence of semantics for the header
      expect(
        tester.getSemantics(find.textContaining('Legal Problem in 3 Taps')),
        matchesSemantics(
          label:
              'Legal Problem in 3 Taps\nGet instant guidance for any consumer issue in India',
          isHeader: true,
        ),
      );

      // Check for Skip button semantics
      expect(
        tester.getSemantics(find.text('Skip')),
        matchesSemantics(
          label: 'Skip',
          isButton: true,
          hasTapAction: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
        ),
      );
    });
  });
}
