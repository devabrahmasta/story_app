import '../../core/api/api_result.dart';
import '../../core/api/api_service.dart';
import '../../core/preferences/auth_preferences.dart';
import '../models/auth_response.dart';

class AuthRepository {
  final ApiService _apiService;
  final AuthPreferences _authPreferences;

  AuthRepository(this._apiService, this._authPreferences);

  Future<Result<AuthResponse>> login(String email, String password) async {
    final result = await _apiService.login(email, password);
    if (result is Success<AuthResponse>) {
      final loginResult = result.data.loginResult;
      if (loginResult != null) {
        await _authPreferences.saveToken(loginResult.token);
        await _authPreferences.saveUserId(loginResult.userId);
        await _authPreferences.saveUserName(loginResult.name);
      }
    }
    return result;
  }

  Future<Result<AuthResponse>> register(
    String name,
    String email,
    String password,
  ) async {
    return await _apiService.register(name, email, password);
  }

  Future<void> logout() async {
    await _authPreferences.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return await _authPreferences.isLoggedIn();
  }
}
