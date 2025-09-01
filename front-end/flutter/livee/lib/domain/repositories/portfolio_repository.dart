import 'dart:convert';

import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/portfolio.dart';

// 포트폴리오 관련 API 호출을 담당
class PortfolioRepository {
  final ApiClient _apiClient = ApiClient();

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
      return Portfolio.fromJson(json);
    } else {
      throw Exception('Failed to load my portfolio');
    }
  }

  // 포트폴리오 정보 부분 수정 (PATCH /portfolios/:id)
  Future<void> updatePortfolio(String id, Map<String, dynamic> data) async {
    // ApiClient에 patch 메소드가 없으므로, put으로 임시 구현하거나 patch를 추가해야 합니다.
    // 여기서는 put을 사용한다고 가정합니다.
    final response = await _apiClient.put('/portfolios/$id', body: data);
    if (response.statusCode != 200) {
      throw Exception('Failed to update portfolio');
    }
  }

  // 추천 쇼호스트 목록 조회 (GET /portfolios/public/featured)
  Future<List<Portfolio>> getFeaturedPortfolios() async {
    final response = await _apiClient.get('/portfolios/public/featured');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Portfolio.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load featured portfolios');
    }
  }
}
