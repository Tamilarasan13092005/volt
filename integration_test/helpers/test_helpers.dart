// integration_test/helpers/test_helpers.dart
//
// Shared setup utilities for VolunteerSync integration tests.
// These helpers make it easy to set up the app and find widgets.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:volunteersync/core/theme/app_theme.dart';
import 'package:volunteersync/providers/auth_provider.dart';
import 'package:volunteersync/providers/dashboard_provider.dart';
import 'package:volunteersync/providers/volunteers_provider.dart';
import 'package:volunteersync/providers/events_provider.dart';
import 'package:volunteersync/providers/chat_provider.dart';
import 'package:volunteersync/routes/app_router.dart';

/// Pumps the full VolunteerSync app with real providers.
/// Use this for end-to-end integration tests.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => VolunteersProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);
          return MaterialApp.router(
            title: 'VolunteerSync Test',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router,
          );
        },
      ),
    ),
  );
}

/// Waits for the app to finish loading (pumps frames until stable).
Future<void> waitForApp(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

/// Enters text into a widget found by its Key.
/// [keyValue] — the string used in Key('keyValue')
/// [text] — the text to enter
Future<void> enterTextByKey(
    WidgetTester tester, String keyValue, String text) async {
  final field = find.byKey(Key(keyValue));
  expect(field, findsOneWidget, reason: 'Widget with key "$keyValue" not found');
  await tester.tap(field);
  await tester.enterText(field, text);
  await tester.pump();
}

/// Taps a widget found by its Key.
Future<void> tapByKey(WidgetTester tester, String keyValue) async {
  final widget = find.byKey(Key(keyValue));
  expect(widget, findsOneWidget, reason: 'Widget with key "$keyValue" not found');
  await tester.tap(widget);
  await tester.pumpAndSettle();
}

/// Checks that a widget with [keyValue] exists on screen.
void expectWidgetWithKey(String keyValue) {
  expect(find.byKey(Key(keyValue)), findsOneWidget,
      reason: 'Expected widget with key "$keyValue" to be visible');
}

/// Checks that a text string appears somewhere on screen.
void expectText(String text) {
  expect(find.text(text), findsOneWidget,
      reason: 'Expected text "$text" to be visible');
}
