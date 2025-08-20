import 'dart:convert';

import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<User> login(String email, String password) async {
    final response = await _apiClient.post(
      '/users/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final user = User.fromJson(json);

      if (user.token != null && user.role != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('liveeToken', user.token!);
        await prefs.setString('liveeRole', user.role!);
      }
      return user;
    } else {
      throw Exception('Failed to login: ${response.reasonPhrase}');
    }
  }

  Future<User> signup(String name, String email, String password, String role) async {
    final response = await _apiClient.post(
      '/users/signup',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final user = User.fromJson(json);
      return user;
    } else {
      throw Exception('Failed to sign up: ${response.reasonPhrase}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('liveeToken');
    await prefs.remove('liveeRole');
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('liveeToken');
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('liveeRole');
  }
}
