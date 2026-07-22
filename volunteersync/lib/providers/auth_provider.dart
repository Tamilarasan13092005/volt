import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }


class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;
  bool _isProfileIncomplete = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isProfileIncomplete => _isProfileIncomplete;

  final _supabase = Supabase.instance.client;

  AuthProvider() {
    _initAuthListener();
    _restoreSession();
  }

  // ── Restore existing Supabase session on app start ─────────────────────
  Future<void> _restoreSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final supaUser = session.user;
      try {
        final res = await _supabase.from('profiles').select().eq('id', supaUser.id).maybeSingle();
        if (res == null) {
          _isProfileIncomplete = true;
          _user = _buildUser(supaUser);
        } else {
          _isProfileIncomplete = false;
          _user = AppUser(
            id: res['id'] ?? supaUser.id,
            name: res['full_name'] ?? supaUser.userMetadata?['full_name'] ?? 'User',
            email: res['email'] ?? supaUser.email ?? '',
            role: res['role'] ?? 'volunteer',
            organization: res['organization'] ?? 'VolunteerSync',
            createdAt: DateTime.tryParse(supaUser.createdAt) ?? DateTime.now(),
            isVerified: supaUser.emailConfirmedAt != null,
          );
        }
      } catch (e) {
        debugPrint('Error restoring profile: $e');
        _isProfileIncomplete = true;
        _user = _buildUser(supaUser);
      }
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Listen for Supabase auth state changes (token refresh, signout) ────
  void _initAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session?.user != null) {
        final supaUser = session!.user;
        try {
          final res = await _supabase.from('profiles').select().eq('id', supaUser.id).maybeSingle();
          if (res == null) {
            _isProfileIncomplete = true;
            _user = _buildUser(supaUser);
          } else {
            _isProfileIncomplete = false;
            _user = AppUser(
              id: res['id'] ?? supaUser.id,
              name: res['full_name'] ?? supaUser.userMetadata?['full_name'] ?? 'User',
              email: res['email'] ?? supaUser.email ?? '',
              role: res['role'] ?? 'volunteer',
              organization: res['organization'] ?? 'VolunteerSync',
              createdAt: DateTime.tryParse(supaUser.createdAt) ?? DateTime.now(),
              isVerified: supaUser.emailConfirmedAt != null,
            );
          }
        } catch (e) {
          debugPrint('Error loading profile: $e');
          _isProfileIncomplete = true;
          _user = _buildUser(supaUser);
        }
        _status = AuthStatus.authenticated;
        notifyListeners();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _isProfileIncomplete = false;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else if (event == AuthChangeEvent.tokenRefreshed &&
          session?.user != null) {
        final supaUser = session!.user;
        try {
          final res = await _supabase.from('profiles').select().eq('id', supaUser.id).maybeSingle();
          if (res == null) {
            _isProfileIncomplete = true;
            _user = _buildUser(supaUser);
          } else {
            _isProfileIncomplete = false;
            _user = AppUser(
              id: res['id'] ?? supaUser.id,
              name: res['full_name'] ?? supaUser.userMetadata?['full_name'] ?? 'User',
              email: res['email'] ?? supaUser.email ?? '',
              role: res['role'] ?? 'volunteer',
              organization: res['organization'] ?? 'VolunteerSync',
              createdAt: DateTime.tryParse(supaUser.createdAt) ?? DateTime.now(),
              isVerified: supaUser.emailConfirmedAt != null,
            );
          }
        } catch (e) {
          _isProfileIncomplete = true;
          _user = _buildUser(supaUser);
        }
        _status = AuthStatus.authenticated;
        notifyListeners();
      }
    });
  }

  AppUser _buildUser(User supaUser) {
    return AppUser(
      id: supaUser.id,
      name: supaUser.userMetadata?['full_name'] as String? ??
          supaUser.email?.split('@')[0] ??
          'User',
      email: supaUser.email ?? '',
      role: supaUser.userMetadata?['role'] as String? ?? 'admin',
      organization:
          supaUser.userMetadata?['organization'] as String? ?? 'VolunteerSync',
      createdAt: DateTime.tryParse(supaUser.createdAt) ?? DateTime.now(),
      isVerified: supaUser.emailConfirmedAt != null,
    );
  }

  // ── Sign In ─────────────────────────────────────────────────────────────
  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    // ── Real Supabase login ───────────────────────────────────────────────
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        _user = _buildUser(response.user!);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Invalid email or password.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Register ────────────────────────────────────────────────────────────
  Future<bool> register(
      String name, String email, String password, String org, {required String role}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name, 'organization': org, 'role': role},
      );

      if (response.user != null) {
        try {
          await _supabase.from('profiles').upsert({
            'id': response.user!.id,
            'full_name': name,
            'email': email.trim(),
            'role': role,
          });
        } catch (_) {
          // profiles table may not exist or already has row — ignore
        }

        if (role == 'volunteer') {
          try {
            await _supabase.from('volunteers').upsert({
              'id': response.user!.id,
              'full_name': name,
              'email': email.trim(),
              'phone': '',
              'status': 'active',
              'skills': [],
              'availability': 'Volunteer',
              'total_hours': 0,
              'rating': 0.0,
              'joined_date': DateTime.now().toIso8601String(),
              'location': '',
              'bio': '',
            });
          } catch (e) {
            debugPrint('Error inserting into volunteers: $e');
          }
        }

        _user = AppUser(
          id: response.user!.id,
          name: name,
          email: email.trim(),
          role: role,
          organization: org,
          createdAt: DateTime.now(),
          isVerified: false,
        );
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed. Please try again.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Forgot Password ─────────────────────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Google Sign In ──────────────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'volunteersync://login-callback',
      );
      return res;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Complete Profile ─────────────────────────────────────────────────────
  Future<bool> completeProfile(String organization, String role) async {
    if (_user == null) return false;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'organization': organization,
            'role': role,
          },
        ),
      );

      await _supabase.from('profiles').upsert({
        'id': _user!.id,
        'full_name': _user!.name,
        'email': _user!.email,
        'role': role,
      });

      if (role == 'volunteer') {
        try {
          await _supabase.from('volunteers').upsert({
            'id': _user!.id,
            'full_name': _user!.name,
            'email': _user!.email,
            'phone': '',
            'status': 'active',
            'skills': [],
            'availability': 'Volunteer',
            'total_hours': 0,
            'rating': 0.0,
            'joined_date': DateTime.now().toIso8601String(),
            'location': '',
            'bio': '',
          });
        } catch (e) {
          debugPrint('Error inserting into volunteers table: $e');
        }
      }

      _user = _user!.copyWith(
        role: role,
        organization: organization,
      );
      _isProfileIncomplete = false;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  void setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
