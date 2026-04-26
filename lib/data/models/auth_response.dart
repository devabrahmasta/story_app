import 'user.dart';

class AuthResponse {
  final bool error;
  final String message;
  final User? loginResult;

  AuthResponse({required this.error, required this.message, this.loginResult});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      error: json['error'],
      message: json['message'],
      loginResult: json['loginResult'] != null
          ? User.fromJson(json['loginResult'])
          : null,
    );
  }
}
