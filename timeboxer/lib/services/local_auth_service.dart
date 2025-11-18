import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalAuthService {
  static const String _userBoxName = 'user_data';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Get user data box
  Box get _userBox => Hive.box(_userBoxName);

  // Initialize the service
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_userBoxName)) {
      await Hive.openBox(_userBoxName);
    }
  }

  // Check if user is logged in
  bool get isLoggedIn {
    return _userBox.get(_isLoggedInKey, defaultValue: false);
  }

  // Get current user name
  String? get currentUserName {
    return _userBox.get(_currentUserKey);
  }

  // Login with username (local only)
  Future<bool> login(String username, String password) async {
    // For local auth, we'll just store the username
    // In a real app, you'd validate credentials
    if (username.isNotEmpty && password.isNotEmpty) {
      await _userBox.put(_currentUserKey, username);
      await _userBox.put(_isLoggedInKey, true);
      return true;
    }
    return false;
  }

  // Register new user (local only)
  Future<bool> register(String username, String password) async {
    // For local auth, we'll just store the username
    if (username.isNotEmpty && password.isNotEmpty) {
      await _userBox.put(_currentUserKey, username);
      await _userBox.put(_isLoggedInKey, true);
      return true;
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    await _userBox.put(_isLoggedInKey, false);
    await _userBox.delete(_currentUserKey);
  }

  // Clear all user data
  Future<void> clearUserData() async {
    await _userBox.clear();
  }
}

// Provider for LocalAuthService
final localAuthServiceProvider = Provider<LocalAuthService>((ref) {
  return LocalAuthService();
});

// Provider for login status
final isLoggedInProvider = Provider<bool>((ref) {
  final authService = ref.watch(localAuthServiceProvider);
  return authService.isLoggedIn;
});

// Provider for current user name
final currentUserNameProvider = Provider<String?>((ref) {
  final authService = ref.watch(localAuthServiceProvider);
  return authService.currentUserName;
});

// Legacy auth service provider for backward compatibility
final authServiceProvider = Provider<LocalAuthService>((ref) {
  return ref.watch(localAuthServiceProvider);
});