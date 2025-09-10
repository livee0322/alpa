import 'dart:convert';

import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/paginated_response.dart';

class CampaignRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<Campaign>> getMyCampaigns() async {
    final response = await _apiClient.get('/campaigns/mine');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return (json['items'] as List).map((e) => Campaign.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load my campaigns');
    }
  }

  Future<PaginatedResponse<Campaign>> getAllCampaigns({
    String? type,
    int? limit,
    int? page,
    String? search,
    String? sort,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (type != null) queryParams['type'] = type;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (sort != null) queryParams['sort'] = sort;

    final response = await _apiClient.get('/campaigns?${Uri(queryParameters: queryParams).query}');

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return PaginatedResponse.fromJson(json, (itemJson) => Campaign.fromJson(itemJson));
    } else {
      throw Exception('Failed to load all campaigns');
    }
  }

  Future<Campaign> getCampaignById(String id) async {
    final response = await _apiClient.get('/campaigns/$id');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return Campaign.fromJson(json['data'] ?? json);
    } else {
      throw Exception('Failed to load campaign by id');
    }
  }

  Future<void> createCampaign(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/campaigns', body: data);
    // 200번대 응답이 아닐 경우, 서버 응답 전문을 Exception으로 전달
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  Future<void> updateCampaign(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/campaigns/$id', body: data);
    // 200번대 응답이 아닐 경우, 서버 응답 전문을 Exception으로 전달
    if (response.statusCode != 200) {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  Future<void> deleteCampaign(String id) async {
    final response = await _apiClient.delete('/campaigns/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete campaign');
    }
  }
}
