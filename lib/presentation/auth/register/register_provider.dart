import 'package:flutter/material.dart';
import '../../../core/api/api_result.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterProvider(this._authRepository);

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

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.register(name, email, password);

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
