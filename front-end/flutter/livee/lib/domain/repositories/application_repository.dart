import 'dart:convert';

import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/portfolio.dart';

/// 지원 관련 API 호출을 담당하는 저장소
class ApplicationRepository {
  final ApiClient _apiClient = ApiClient();

  /// 특정 공고에 지원서를 제출
  Future<void> createApplication({
    required String campaignId,
    required String portfolioId,
    required String message,
  }) async {
    final response = await _apiClient.post(
      '/applications',
      body: {
        'campaignId': campaignId,
        'profileRef': portfolioId,
        'message': message,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to create application: ${response.body}');
    }
  }

  /// 특정 공고의 지원자 목록을 조회
  Future<List<Portfolio>> getApplicantsForCampaign(String campaignId) async {
    final response = await _apiClient.get('/applications?campaignId=$campaignId');

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      // 응답 데이터 구조에 따라 'items' 또는 최상위 리스트를 파싱
      final List<dynamic> jsonList = json['items'] ?? json['data'] ?? json;
      return jsonList.map((item) => Portfolio.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load applicants');
    }
  }
}
