import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  AuthProvider(this._authRepository) {
    _init();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    _isLoggedIn = await _authRepository.isLoggedIn();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login() async {
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
