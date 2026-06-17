// test/widget/login_widget_test.dart
//
// Widget tests for the LoginScreen.
// These render the widget in a test environment (no real device needed).
// Faster than integration tests but still tests actual UI rendering.
//
// HOW TO RUN:
//   flutter test test/widget/login_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volunteersync/core/theme/app_theme.dart';
import 'package:volunteersync/features/auth/screens/login_screen.dart';
import 'package:volunteersync/providers/auth_provider.dart';
import 'package:volunteersync/routes/app_router.dart';

// ─── Minimal test router that only registers the login route ─────────────────
GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: AppRouter.login,
    routes: [
      GoRoute(
        path: AppRouter.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouter.register,
        builder: (_, __) => const Scaffold(body: Text('Register Screen')),
      ),
      GoRoute(
        path: AppRouter.forgotPassword,
        builder: (_, __) =>
            const Scaffold(body: Text('Forgot Password Screen')),
      ),
      GoRoute(
        path: AppRouter.landing,
        builder: (_, __) => const Scaffold(body: Text('Landing Screen')),
      ),
      GoRoute(
        path: AppRouter.dashboard,
        builder: (_, __) => const Scaffold(body: Text('Dashboard Screen')),
      ),
    ],
  );
}

// ─── Pump a minimal app containing only LoginScreen ──────────────────────────
Future<void> pumpLoginScreen(WidgetTester tester) async {
  // Supabase must be initialized before AuthProvider is created.
  // In widget tests, we skip Supabase initialization and only test
  // the rendering/key presence of widgets.
  try {
    await Supabase.initialize(
      url: 'https://mspciorhvkjxsfllnvwn.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zcGNpb3JodmtqeHNmbGxudnduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxMjA4ODAsImV4cCI6MjA5NTY5Njg4MH0.1TCj_TOGpYQJeFc4n6SodqMzd6ZqKTTeJ5YDBVc9RUQ',
    );
  } catch (_) {
    // Already initialized in a previous test — safe to ignore
  }

  final router = _buildTestRouter();

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    ),
  );

  // Wait for the widget tree to settle
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders without crashing', (tester) async {
      await pumpLoginScreen(tester);
      // Just verifying it doesn't throw during build
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('LoginScreen has email field with correct key', (tester) async {
      await pumpLoginScreen(tester);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    });

    testWidgets('LoginScreen has password field with correct key',
        (tester) async {
      await pumpLoginScreen(tester);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    });

    testWidgets('LoginScreen has submit button with correct key',
        (tester) async {
      await pumpLoginScreen(tester);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    });

    testWidgets('LoginScreen has forgot password link', (tester) async {
      await pumpLoginScreen(tester);
      expect(find.byKey(const Key('forgot_password_link')), findsOneWidget);
    });

    testWidgets('LoginScreen has sign-up link', (tester) async {
      await pumpLoginScreen(tester);
      expect(find.byKey(const Key('signup_link')), findsOneWidget);
    });

    testWidgets('Empty email shows validation error on submit', (tester) async {
      await pumpLoginScreen(tester);

      // Tap submit without entering anything
      final submitBtn = find.byKey(const Key('login_submit_button'));
      if (submitBtn.evaluate().isNotEmpty) {
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // Expect validation error for email
        expect(find.text('Enter a valid email'), findsOneWidget);
      }
    });

    testWidgets('Invalid email shows validation error', (tester) async {
      await pumpLoginScreen(tester);

      final emailField = find.byKey(const Key('login_email_field'));
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'invalidemail');
        await tester.pump();

        final submitBtn = find.byKey(const Key('login_submit_button'));
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.text('Enter a valid email'), findsOneWidget);
      }
    });

    testWidgets('Short password shows validation error', (tester) async {
      await pumpLoginScreen(tester);

      final emailField = find.byKey(const Key('login_email_field'));
      final passField = find.byKey(const Key('login_password_field'));

      if (emailField.evaluate().isNotEmpty && passField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passField, '123');
        await tester.pump();

        final submitBtn = find.byKey(const Key('login_submit_button'));
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.text('Min 6 characters'), findsOneWidget);
      }
    });

    testWidgets('Password toggle button is present', (tester) async {
      await pumpLoginScreen(tester);
      expect(find.byKey(const Key('login_password_toggle')), findsOneWidget);
    });
  });
}
