import 'dart:convert';

import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/portfolio.dart';

// 포트폴리오 관련 API 호출을 담당
class PortfolioRepository {
  final ApiClient _apiClient = ApiClient();

  // ID로 특정 포트폴리오 '단건' 조회
  Future<Portfolio> getPortfolioById(String id) async {
    final response = await _apiClient.get('/portfolios/$id');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return Portfolio.fromJson(json['data'] ?? json);
    } else {
      throw Exception('Failed to load portfolio by id');
    }
  }

  // 내 포트폴리오 '목록' 조회
  Future<List<Portfolio>> getMyPortfolioList() async {
    final response = await _apiClient.get('/portfolios/my/list');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> jsonList = json['items'] ?? json['data'] ?? json;
      return jsonList.map((json) => Portfolio.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load my portfolio list');
    }
  }

  // 포트폴리오 생성
  Future<void> createPortfolio(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/portfolios', body: data);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to create portfolio: ${response.body}');
    }
  }

  // 특정 포트폴리오 수정
  Future<void> updatePortfolio(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/portfolios/$id', body: data);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update portfolio: ${response.body}');
    }
  }

  // 특정 포트폴리오 삭제
  Future<void> deletePortfolio(String id) async {
    final response = await _apiClient.delete('/portfolios/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete portfolio');
    }
  }

  // 공개된 모든 쇼호스트 포트폴리오 목록을 가져오기
  Future<List<Portfolio>> getAllPublicPortfolios() async {
    final response = await _apiClient.get('/portfolio/all');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Portfolio.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load portfolios');
    }
  }

  // 내 포트폴리오 조회 (GET /portfolios/my)
  Future<Portfolio> getMyPortfolio() async {
    final response = await _apiClient.get('/portfolios/my');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return Portfolio.fromJson(json['data'] ?? json);
    } else {
      throw Exception('Failed to load my portfolio');
    }
  }

  // 내 포트폴리오 저장/수정 (PUT /portfolios/my)
  Future<void> saveMyPortfolio(Map<String, dynamic> data) async {
    final response = await _apiClient.put('/portfolios/my', body: data);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to save portfolio: ${response.body}');
    }
  }

  // 공개된 포트폴리오 목록 조회 (limit 지원)
  Future<List<Portfolio>> getPublicPortfolios({int? limit}) async {
    final path = '/portfolios${limit != null ? '?limit=$limit' : ''}';
    final response = await _apiClient.get(path);

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> jsonList = json['items'] ?? json['data'] ?? json;
      return jsonList.map((json) => Portfolio.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load public portfolios');
    }
  }
}
