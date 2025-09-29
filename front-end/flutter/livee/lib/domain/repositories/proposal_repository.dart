import 'dart:convert';
import 'package:livee/data/core/api_client.dart';

/// '제안하기' 관련 API 호출을 담당하는 저장소
class ProposalRepository {
  final ApiClient _apiClient = ApiClient();

  /// 새로운 제안을 생성 (POST /proposals)
  Future<void> createProposal(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/proposals', body: data);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // API 실패 시, 서버가 보낸 에러 메시지를 그대로 전달
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }
}
