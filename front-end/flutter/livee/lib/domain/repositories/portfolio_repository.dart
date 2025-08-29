import 'dart:convert';

import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/portfolio.dart';

// 포트폴리오 관련 API 호출을 담당
class PortfolioRepository {
  final ApiClient _apiClient = ApiClient();

  // 공개된 모든 쇼호스트 포트폴리오 목록을 가져옵니다.
  Future<List<Portfolio>> getAllPublicPortfolios() async {
    final response = await _apiClient.get('/portfolio/all');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Portfolio.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load portfolios');
    }
  }
}
