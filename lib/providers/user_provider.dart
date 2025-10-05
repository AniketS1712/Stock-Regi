import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:stock_register/models/user_model.dart';
import 'package:stock_register/service/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  fb.User? _firebaseUser;
  fb.User? get firebaseUser => _firebaseUser;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null && _currentUser != null;

  UserProvider() {
    _initAuthListener();
  }

  /// 🔹 Listen to FirebaseAuth state changes
  void _initAuthListener() {
    _userService.auth.authStateChanges().listen((user) async {
      _firebaseUser = user;

      if (user != null) {
        _setLoading(true);
        try {
          _currentUser = await _userService.getUserById(user.uid);
          if (_currentUser != null) {
            await _userService.updateLastLogin(user.uid);
          }
        } catch (e) {
          _setError("Failed to fetch user profile: $e");
        }
        _setLoading(false);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  /// 🔹 SIGN UP
  Future<bool> signup({
    required String fullName,
    required String username,
    required String companyName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final profile = await _userService.signup(
        fullName: fullName,
        username: username,
        companyName: companyName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      // Auth listener will update state anyway, but set now for immediacy
      _firebaseUser = _userService.currentUser;
      _currentUser = profile;

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 LOGIN
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);

    try {
      final profile = await _userService.login(
        email: email,
        password: password,
      );

      if (profile == null) {
        _setError("No profile found for this account.");
        return false;
      }

      _firebaseUser = _userService.currentUser;
      _currentUser = profile;
      await _userService.updateLastLogin(profile.id);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 SIGN OUT
  Future<void> signOut() async {
    await _userService.logout();
    _firebaseUser = null;
    _currentUser = null;
    notifyListeners();
  }

  // Helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
