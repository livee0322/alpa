import 'dart:convert';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/models/proposal.dart';

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

  // 보낸 제안 목록 조회 (GET /proposals/sent)
  Future<PaginatedResponse<Proposal>> getSentProposals({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status != 'all') {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get('/proposals/sent?${Uri(queryParameters: queryParams).query}');

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return PaginatedResponse.fromJson(json, (itemJson) => Proposal.fromJson(itemJson));
    } else {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

// 받은 제안 목록 조회 (GET /proposals/received)
  Future<PaginatedResponse<Proposal>> getReceivedProposals({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status != 'all') {
      queryParams['status'] = status;
    }
    final response = await _apiClient.get('/proposals/received?${Uri(queryParameters: queryParams).query}');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return PaginatedResponse.fromJson(json, (itemJson) => Proposal.fromJson(itemJson));
    } else {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  // 제안 철회 (PATCH /proposals/:id/withdraw)
  Future<void> withdrawProposal(String proposalId) async {
    final response = await _apiClient.patch('/proposals/$proposalId/withdraw');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }
}
