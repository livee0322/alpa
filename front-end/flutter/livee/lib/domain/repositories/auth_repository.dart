import 'dart:convert';

import 'package:livee/data/core/api_client.dart';
import 'package:livee/data/core/session_storage_service.dart';
import 'package:livee/domain/models/user.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<User> login(String email, String password, String role) async {
    final response = await _apiClient.post(
      '/users/login',
      body: {
        'email': email,
        'password': password,
        'role': role,
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final user = User.fromJson(json);

      if (user.token != null && user.role != null) {
        SessionStorageService.write('liveeToken', user.token!);
        SessionStorageService.write('liveeRole', user.role!);
      }
      return user;
    } else {
      // [수정] 서버에서 보내주는 실제 에러 메시지를 파싱하여 Exception으로 전달
      // final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
      // final message = errorJson['message'] ?? '로그인에 실패했습니다.';
      final message = '로그인에 실패했습니다.';
      throw Exception(message);
    }
  }

  Future<User> signup(
      String name, String email, String password, String role) async {
    final response = await _apiClient.post(
      '/users/signup',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 200번대 응답 코드는 성공으로 처리
      final user = User.fromJson(data);
      return user;
    } else {
      // 200번대 외의 응답 코드는 실패로 처리
      final message = data['message'] ?? '가입 실패';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    SessionStorageService.delete('liveeToken');
    SessionStorageService.delete('liveeRole');
  }

  Future<String?> getAuthToken() async {
    return SessionStorageService.read('liveeToken');
  }

  Future<String?> getUserRole() async {
    return SessionStorageService.read('liveeRole');
  }
}
