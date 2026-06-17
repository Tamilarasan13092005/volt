// test/widget/register_widget_test.dart
//
// Widget tests for the RegisterScreen.
//
// HOW TO RUN:
//   flutter test test/widget/register_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volunteersync/core/theme/app_theme.dart';
import 'package:volunteersync/features/auth/screens/register_screen.dart';
import 'package:volunteersync/providers/auth_provider.dart';
import 'package:volunteersync/routes/app_router.dart';

GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: AppRouter.register,
    routes: [
      GoRoute(
        path: AppRouter.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRouter.login,
        builder: (_, __) => const Scaffold(body: Text('Login Screen')),
      ),
      GoRoute(
        path: AppRouter.dashboard,
        builder: (_, __) => const Scaffold(body: Text('Dashboard Screen')),
      ),
    ],
  );
}

Future<void> pumpRegisterScreen(WidgetTester tester) async {
  try {
    await Supabase.initialize(
      url: 'https://mspciorhvkjxsfllnvwn.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zcGNpb3JodmtqeHNmbGxudnduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxMjA4ODAsImV4cCI6MjA5NTY5Njg4MH0.1TCj_TOGpYQJeFc4n6SodqMzd6ZqKTTeJ5YDBVc9RUQ',
    );
  } catch (_) {
    // Already initialized — safe to ignore
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

  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  group('RegisterScreen Widget Tests', () {
    testWidgets('RegisterScreen renders without crashing', (tester) async {
      await pumpRegisterScreen(tester);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('RegisterScreen has Full Name field', (tester) async {
      await pumpRegisterScreen(tester);
      expect(find.byKey(const Key('register_name_field')), findsOneWidget);
    });

    testWidgets('RegisterScreen has Organization field', (tester) async {
      await pumpRegisterScreen(tester);
      expect(find.byKey(const Key('register_org_field')), findsOneWidget);
    });

    testWidgets('RegisterScreen has Email field', (tester) async {
      await pumpRegisterScreen(tester);
      expect(find.byKey(const Key('register_email_field')), findsOneWidget);
    });

    testWidgets('RegisterScreen has Password field', (tester) async {
      await pumpRegisterScreen(tester);
      expect(find.byKey(const Key('register_password_field')), findsOneWidget);
    });

    testWidgets('RegisterScreen has Terms checkbox', (tester) async {
      await pumpRegisterScreen(tester);
      expect(
          find.byKey(const Key('register_terms_checkbox')), findsOneWidget);
    });

    testWidgets('RegisterScreen has Create Account button', (tester) async {
      await pumpRegisterScreen(tester);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
    });

    testWidgets('RegisterScreen has sign-in link', (tester) async {
      await pumpRegisterScreen(tester);
      expect(find.byKey(const Key('signin_link')), findsOneWidget);
    });

    testWidgets('Empty form submission shows validation errors', (tester) async {
      await pumpRegisterScreen(tester);

      final submitBtn = find.byKey(const Key('register_submit_button'));
      if (submitBtn.evaluate().isNotEmpty) {
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // At least one validation error should appear
        expect(
          find.textContaining('Enter').evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected at least one validation error',
        );
      }
    });

    testWidgets('Short name (1 char) shows validation error', (tester) async {
      await pumpRegisterScreen(tester);

      final nameField = find.byKey(const Key('register_name_field'));
      if (nameField.evaluate().isNotEmpty) {
        await tester.enterText(nameField, 'A'); // Too short
        await tester.pump();

        final submitBtn = find.byKey(const Key('register_submit_button'));
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.text('Enter your name'), findsOneWidget);
      }
    });

    testWidgets('Invalid email shows validation error', (tester) async {
      await pumpRegisterScreen(tester);

      final nameField = find.byKey(const Key('register_name_field'));
      final orgField = find.byKey(const Key('register_org_field'));
      final emailField = find.byKey(const Key('register_email_field'));

      if (nameField.evaluate().isNotEmpty &&
          orgField.evaluate().isNotEmpty &&
          emailField.evaluate().isNotEmpty) {
        await tester.enterText(nameField, 'John Doe');
        await tester.enterText(orgField, 'Acme Corp');
        await tester.enterText(emailField, 'notanemail');
        await tester.pump();

        final submitBtn = find.byKey(const Key('register_submit_button'));
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.text('Enter a valid email'), findsOneWidget);
      }
    });

    testWidgets('Short password shows min 8 chars validation error',
        (tester) async {
      await pumpRegisterScreen(tester);

      final nameField = find.byKey(const Key('register_name_field'));
      final orgField = find.byKey(const Key('register_org_field'));
      final emailField = find.byKey(const Key('register_email_field'));
      final passField = find.byKey(const Key('register_password_field'));

      if (nameField.evaluate().isNotEmpty &&
          passField.evaluate().isNotEmpty) {
        await tester.enterText(nameField, 'John Doe');
        await tester.enterText(orgField, 'Acme Corp');
        await tester.enterText(emailField, 'john@example.com');
        await tester.enterText(passField, 'abc'); // Too short
        await tester.pump();

        final submitBtn = find.byKey(const Key('register_submit_button'));
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.text('Min 8 characters'), findsOneWidget);
      }
    });
  });
}
