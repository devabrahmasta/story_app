import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../data/models/auth_response.dart';
import '../../data/models/story.dart';
import '../preferences/auth_preferences.dart';
import 'api_result.dart';

class ApiService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1';
  final AuthPreferences _authPreferences;
  void Function()? onUnauthorized;

  ApiService(this._authPreferences, {this.onUnauthorized});

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authPreferences.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _handleUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      _authPreferences.clearAll();
      if (onUnauthorized != null) {
        onUnauthorized!();
      }
    }
  }

  Future<Result<AuthResponse>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return Success(AuthResponse.fromJson(data));
      } else {
        return Error(data['message'] ?? 'Failed to register');
      }
    } catch (e) {
      return Error('An error occurred: $e');
    }
  }

  Future<Result<AuthResponse>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Success(AuthResponse.fromJson(data));
      } else {
        return Error(data['message'] ?? 'Failed to login');
      }
    } catch (e) {
      return Error('An error occurred: $e');
    }
  }

  Future<Result<List<Story>>> getStories({int page = 1, int size = 10}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/stories?page=$page&size=$size'),
        headers: headers,
      );

      _handleUnauthorized(response);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> list = data['listStory'];
        final stories = list.map((json) => Story.fromJson(json)).toList();
        return Success(stories);
      } else {
        return Error(data['message'] ?? 'Failed to fetch stories');
      }
    } catch (e) {
      return Error('An error occurred: $e');
    }
  }

  Future<Result<Story>> getStoryDetail(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/stories/$id'),
        headers: headers,
      );

      _handleUnauthorized(response);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Success(Story.fromJson(data['story']));
      } else {
        return Error(data['message'] ?? 'Failed to fetch story detail');
      }
    } catch (e) {
      return Error('An error occurred: $e');
    }
  }

  Future<Result<bool>> addStory(File photo, String description) async {
    try {
      final token = await _authPreferences.getToken();
      final request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/stories'))
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['description'] = description
            ..files.add(await http.MultipartFile.fromPath('photo', photo.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _handleUnauthorized(response);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return const Success(true);
      } else {
        return Error(data['message'] ?? 'Failed to upload story');
      }
    } catch (e) {
      return Error('An error occurred: $e');
    }
  }
}
