import 'package:flutter/material.dart';
import '../../../core/api/api_result.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginProvider(this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.login(email, password);

    _isLoading = false;
    if (result is Success) {
      notifyListeners();
      return true;
    } else if (result is Error) {
      _errorMessage = (result as Error).message;
      notifyListeners();
      return false;
    }
    return false;
  }
}
