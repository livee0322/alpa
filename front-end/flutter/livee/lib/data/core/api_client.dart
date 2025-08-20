import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _apiBase = 'https://main-server-ekgr.onrender.com/api/v1';

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('liveeToken');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$_apiBase$path');
    final headers = await _getAuthHeaders();
    return http.get(uri, headers: headers);
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_apiBase$path');
    final headers = await _getAuthHeaders();
    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_apiBase$path');
    final headers = await _getAuthHeaders();
    return http.put(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$_apiBase$path');
    final headers = await _getAuthHeaders();
    return http.delete(uri, headers: headers);
  }
}
