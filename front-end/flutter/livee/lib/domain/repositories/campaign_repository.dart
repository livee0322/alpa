import 'dart:convert';

import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/campaign.dart';

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

  Future<List<Campaign>> getAllCampaigns({String? type, int? limit}) async {
    final Map<String, dynamic> queryParams = {};
    if (type != null) queryParams['type'] = type;
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _apiClient.get('/campaigns?${Uri(queryParameters: queryParams).query}');

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      // main.js의 getJson 함수 로직처럼 다양한 응답 구조를 처리합니다.
      final items = json['items'] ?? json['data']?['items'] ?? json['docs'] ?? json['data']?['docs'] ?? [];
      return (items as List).map((e) => Campaign.fromJson(e)).toList();
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
    if (response.statusCode != 200) {
      throw Exception('Failed to create campaign');
    }
  }

  Future<void> updateCampaign(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/campaigns/$id', body: data);
    if (response.statusCode != 200) {
      throw Exception('Failed to update campaign');
    }
  }

  Future<void> deleteCampaign(String id) async {
    final response = await _apiClient.delete('/campaigns/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete campaign');
    }
  }
}
