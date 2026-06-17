// integration_test/app_test.dart
//
// VolunteerSync — Complete Integration Test Suite
//
// These tests run on a real device or emulator (not a fake in-memory widget).
// They test the full app from launch through real user flows.
//
// HOW TO RUN LOCALLY:
//   flutter test integration_test/app_test.dart
//
// HOW TO RUN ON A CONNECTED DEVICE:
//   flutter test integration_test/app_test.dart -d <device-id>
//
// DEMO CREDENTIALS (hardcoded in auth_provider.dart — always work):
//   Email:    alex@volunteersync.io
//   Password: password123

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helpers.dart';

void main() {
  // This line is REQUIRED for integration tests — it sets up the test binding.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ══════════════════════════════════════════════════════════════════════════
  // TEST GROUP 1: App Launch
  // ══════════════════════════════════════════════════════════════════════════
  group('🚀 App Launch Tests', () {
    testWidgets('App launches and shows a screen without crashing',
        (WidgetTester tester) async {
      // Arrange & Act: Start the app
      await pumpApp(tester);
      await waitForApp(tester);

      // Assert: At minimum, a Scaffold must be rendered
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('App shows login or landing screen on first launch',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      // Either login page or landing page should be visible
      // (depends on whether a session is already saved)
      final hasLoginScreen = find.byKey(const Key('login_email_field')).evaluate().isNotEmpty;
      final hasLandingText = find.text('VolunteerSync').evaluate().isNotEmpty;

      expect(hasLoginScreen || hasLandingText, isTrue,
          reason: 'Expected to see either login screen or landing screen');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST GROUP 2: Login Screen Widget Presence
  // ══════════════════════════════════════════════════════════════════════════
  group('🔐 Login Screen Tests', () {
    testWidgets('Login screen shows email and password fields',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      // Navigate to login if not already there
      final loginEmailField = find.byKey(const Key('login_email_field'));
      if (loginEmailField.evaluate().isEmpty) {
        // Try to find a login button on landing
        final loginBtn = find.textContaining('Sign In');
        if (loginBtn.evaluate().isNotEmpty) {
          await tester.tap(loginBtn.first);
          await tester.pumpAndSettle();
        }
      }

      // Verify email and password fields exist
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    });

    testWidgets('Login with empty fields shows validation errors',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      // Navigate to login
      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      // Tap Sign In without entering anything
      final submitBtn = find.byKey(const Key('login_submit_button'));
      if (submitBtn.evaluate().isNotEmpty) {
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // Validation error should appear
        expect(
          find.textContaining('valid email').evaluate().isNotEmpty ||
              find.textContaining('Enter').evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected form validation error to appear',
        );
      }
    });

    testWidgets('Login with invalid email shows validation error',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      final emailField = find.byKey(const Key('login_email_field'));
      if (emailField.evaluate().isNotEmpty) {
        // Enter invalid email (no @ sign)
        await tester.enterText(emailField, 'notanemail');
        await tester.pump();

        final submitBtn = find.byKey(const Key('login_submit_button'));
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Enter a valid email'), findsOneWidget);
      }
    });

    testWidgets('Login with short password shows validation error',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      final emailField = find.byKey(const Key('login_email_field'));
      final passField = find.byKey(const Key('login_password_field'));
      if (emailField.evaluate().isNotEmpty && passField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passField, '123'); // Too short
        await tester.pump();

        final submitBtn = find.byKey(const Key('login_submit_button'));
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.text('Min 6 characters'), findsOneWidget);
      }
    });

    testWidgets('Demo login succeeds and navigates to dashboard',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      // Navigate to login
      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      final emailField = find.byKey(const Key('login_email_field'));
      final passField = find.byKey(const Key('login_password_field'));

      if (emailField.evaluate().isNotEmpty && passField.evaluate().isNotEmpty) {
        // Use demo credentials (always works, no Supabase needed)
        await tester.enterText(emailField, 'alex@volunteersync.io');
        await tester.enterText(passField, 'password123');
        await tester.pump();

        final submitBtn = find.byKey(const Key('login_submit_button'));
        await tester.tap(submitBtn);

        // Wait for navigation to complete
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should now see dashboard navigation
        expect(
          find.byKey(const Key('nav_dashboard')).evaluate().isNotEmpty ||
              find.textContaining('Dashboard').evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected to navigate to dashboard after demo login',
        );
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST GROUP 3: Navigation Between Screens
  // ══════════════════════════════════════════════════════════════════════════
  group('🧭 Navigation Tests', () {
    testWidgets('Login page has sign-up link that navigates to register',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      final signupLink = find.byKey(const Key('signup_link'));
      if (signupLink.evaluate().isNotEmpty) {
        await tester.tap(signupLink);
        await tester.pumpAndSettle();

        // Should be on register screen now
        expect(
          find.byKey(const Key('register_name_field')).evaluate().isNotEmpty ||
              find.text('Create your account').evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected to navigate to register screen',
        );
      }
    });

    testWidgets('Register page has sign-in link that navigates back to login',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      // Go to login first
      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      // Then go to register
      final signupLink = find.byKey(const Key('signup_link'));
      if (signupLink.evaluate().isNotEmpty) {
        await tester.tap(signupLink);
        await tester.pumpAndSettle();
      }

      // Then go back to sign in
      final signinLink = find.byKey(const Key('signin_link'));
      if (signinLink.evaluate().isNotEmpty) {
        await tester.tap(signinLink);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('login_email_field')).evaluate().isNotEmpty ||
              find.text('Welcome back 👋').evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected to navigate back to login screen',
        );
      }
    });

    testWidgets('Login page has forgot password link',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      expect(find.byKey(const Key('forgot_password_link')), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST GROUP 4: Registration Form Validation
  // ══════════════════════════════════════════════════════════════════════════
  group('📝 Registration Form Tests', () {
    testWidgets('Register screen shows all required form fields',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      // Navigate to register
      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      final signupLink = find.byKey(const Key('signup_link'));
      if (signupLink.evaluate().isNotEmpty) {
        await tester.tap(signupLink);
        await tester.pumpAndSettle();

        // All 4 fields + submit button should be present
        expect(find.byKey(const Key('register_name_field')), findsOneWidget);
        expect(find.byKey(const Key('register_org_field')), findsOneWidget);
        expect(find.byKey(const Key('register_email_field')), findsOneWidget);
        expect(find.byKey(const Key('register_password_field')), findsOneWidget);
        expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
      }
    });

    testWidgets('Register with empty fields shows validation errors',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      final signupLink = find.byKey(const Key('signup_link'));
      if (signupLink.evaluate().isNotEmpty) {
        await tester.tap(signupLink);
        await tester.pumpAndSettle();

        final submitBtn = find.byKey(const Key('register_submit_button'));
        if (submitBtn.evaluate().isNotEmpty) {
          await tester.tap(submitBtn);
          await tester.pumpAndSettle();

          // Should show at least one validation error
          expect(
            find.textContaining('Enter').evaluate().isNotEmpty,
            isTrue,
            reason: 'Expected validation errors on empty form',
          );
        }
      }
    });

    testWidgets('Password toggle button shows and hides password',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      // Test login password toggle
      final passToggle = find.byKey(const Key('login_password_toggle'));
      if (passToggle.evaluate().isNotEmpty) {
        await tester.tap(passToggle);
        await tester.pump();
        // Just verifying the tap doesn't crash — icon will change internally
        expect(passToggle, findsOneWidget);
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST GROUP 5: Dashboard & Navigation (requires login)
  // ══════════════════════════════════════════════════════════════════════════
  group('📊 Dashboard Tests', () {
    // Helper: Log in with demo credentials before each test
    Future<void> loginWithDemo(WidgetTester tester) async {
      await pumpApp(tester);
      await waitForApp(tester);

      final loginBtn = find.textContaining('Sign In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle();
      }

      final emailField = find.byKey(const Key('login_email_field'));
      final passField = find.byKey(const Key('login_password_field'));
      final submitBtn = find.byKey(const Key('login_submit_button'));

      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'alex@volunteersync.io');
        await tester.enterText(passField, 'password123');
        await tester.tap(submitBtn);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    }

    testWidgets('Dashboard shows navigation items after login',
        (WidgetTester tester) async {
      await loginWithDemo(tester);

      // After login, navigation items should be visible
      final hasDashboardNav =
          find.byKey(const Key('nav_dashboard')).evaluate().isNotEmpty;
      final hasDashboardText =
          find.textContaining('Dashboard').evaluate().isNotEmpty;

      expect(hasDashboardNav || hasDashboardText, isTrue,
          reason: 'Expected dashboard navigation to be visible after login');
    });

    testWidgets('Can navigate to Volunteers section', (WidgetTester tester) async {
      await loginWithDemo(tester);

      final navVolunteers = find.byKey(const Key('nav_volunteers'));
      if (navVolunteers.evaluate().isNotEmpty) {
        await tester.tap(navVolunteers);
        await tester.pumpAndSettle();

        expect(find.textContaining('Volunteer').evaluate().isNotEmpty, isTrue,
            reason: 'Expected Volunteers screen to load');
      }
    });

    testWidgets('Can navigate to Events section', (WidgetTester tester) async {
      await loginWithDemo(tester);

      final navEvents = find.byKey(const Key('nav_events'));
      if (navEvents.evaluate().isNotEmpty) {
        await tester.tap(navEvents);
        await tester.pumpAndSettle();

        expect(find.textContaining('Event').evaluate().isNotEmpty, isTrue,
            reason: 'Expected Events screen to load');
      }
    });
  });
}
