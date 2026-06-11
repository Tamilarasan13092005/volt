import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  final _supabase = Supabase.instance.client;

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = AppUser(
          id: response.user!.id,
          name: response.user!.email?.split('@')[0] ?? 'User',
          email: response.user!.email ?? '',
          role: 'admin',
          organization: 'VolunteerSync',
          createdAt: DateTime.now(),
          isVerified: true,
        );
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Invalid email or password.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String org) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'full_name': name,
          'email': email,
          'role': 'admin',
        });

        _user = AppUser(
          id: response.user!.id,
          name: name,
          email: email,
          role: 'admin',
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
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
