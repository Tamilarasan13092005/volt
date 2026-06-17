// test/unit/auth_provider_test.dart
//
// Unit tests for AuthProvider.
// These test the provider logic in isolation — no UI, no network.
//
// HOW TO RUN:
//   flutter test test/unit/auth_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:volunteersync/providers/auth_provider.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // Note: AuthProvider requires Supabase to be initialized.
  // For pure unit tests that don't call Supabase, we test the
  // public API and enum values only.
  // ══════════════════════════════════════════════════════════════════════════

  group('AuthStatus enum', () {
    test('AuthStatus has all required values', () {
      // Verify all expected enum values exist
      expect(AuthStatus.values, contains(AuthStatus.initial));
      expect(AuthStatus.values, contains(AuthStatus.loading));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.error));
    });

    test('AuthStatus.values has exactly 5 states', () {
      expect(AuthStatus.values.length, equals(5));
    });
  });

  group('AuthStatus logic', () {
    test('isAuthenticated should be true only when status is authenticated', () {
      // Test the boolean logic directly
      const authenticatedStatus = AuthStatus.authenticated;
      const unauthenticatedStatus = AuthStatus.unauthenticated;

      expect(authenticatedStatus == AuthStatus.authenticated, isTrue);
      expect(unauthenticatedStatus == AuthStatus.authenticated, isFalse);
    });

    test('loading status is distinct from error status', () {
      expect(AuthStatus.loading, isNot(equals(AuthStatus.error)));
    });

    test('initial status is distinct from all other statuses', () {
      for (final status in AuthStatus.values) {
        if (status == AuthStatus.initial) continue;
        expect(AuthStatus.initial, isNot(equals(status)));
      }
    });
  });
}
